require "movies_report/version"
require "movies_report/sanitizer/chomikuj"
require 'nokogiri'
require "net/http"
require "uri"
require "awesome_print"
require "imdb"

# TODO: use better config tool
$MOVIES_REPORT_DEBUG = false

module MoviesReport

  # HtmlPage
  # - fetches html page
  # - uses Nokogiri, Net:HTTP
  class HtmlPage
    attr_reader :uri, :document

    def initialize(uri)
      @uri = uri
      @document = Nokogiri::HTML(Net::HTTP.get_response(@uri).body)
    rescue => e
      ap "Cant fetch page from : '#{@uri}' #{e.message}"
      ap e.backtrace
      nil
    end
  end

  module Movie

    # Movie::Chomikuj:
    # - takes service specific uri
    # - finds all movies information on given service page
    # - provides iterator, which yields all found movies with their page-specific properties
    #   (i.e. title + size + comment)
    class Chomikuj

      def initialize(uri)
        @document = HtmlPage.new(uri).document
      end

      def each_movie(&block)
        return unless @document

        pages = { 
          folder_list: {
            selector: '#foldersList a',
            fields: {
              title: ->(el) { sanitize_title(el.content.strip) }
            }
          },
          file_list: {
            selector: '#FilesListContainer .fileItemContainer',
            fields: {
              title: ->(el) { sanitize_title(el.css('.filename').first.content.strip) },
              size:  ->(el) { el.css('.fileinfo li:nth-last-child(2)').first.content }
            }
          }
        }

        page_type = @document.css('.noFile').empty? ? :file_list : :folder_list
        page = pages[page_type]

        @document.css(page[:selector]).map do |el|
          # build properties structure: [ [ 'title', 'XXX' ], [ 'size', '200' ] ]
          movie_properties = page[:fields].map { |field, value_proc| [field, value_proc.call(el) ]}

          # yield properties as hashes: {:title => 'XXX', :size => '200'}
          yield(Hash[movie_properties])
        end
      end

      private

      def sanitize_title(original_title)
        MoviesReport::Sanitizer::Chomikuj.clean(original_title)
      end

    end
  end

  # Report:
  # - takes movies data source class
  # - for each movie from data source, create rankings
  #
  class Report

    def initialize(movies_url, movies_source_engine)
      @movies_uri    = URI(movies_url)
      @movies_source = movies_source_engine.new(@movies_uri)
    end

    def build!
      @movies_source.each_movie do |movie|
        title    = movie[:title]
        rankings = build_rankings(title)

        ap "* #{title} [#{rankings.inspect}]" if $MOVIES_REPORT_DEBUG

        { title: title, ratings: rankings }
      end
    end

    def build_rankings(title)
      { filmweb: Search::Filmweb.new(title).rating,
        imdb:    Search::IMDB.new(title).rating }
    end
  end

  module Search

    # Base class for all html-page based searchers
    # - takes movie title to search for
    # - searches immediately when instance is created
    # - #read_results must be implemented in concrete classes
    #
    class BaseSearch

      def initialize(title)
        @title = title
        @results = read_results
      end

      def read_results
        raise NotImplementedError,
              'This is an abstract base method. Implement in your subclass.'
      end
    end

    # use the gem
    class IMDB < BaseSearch

      def rating
        movie = @results.first
        movie.rating if movie
      end

      def read_results
        Imdb::Search.new(@title).movies
      rescue => e
        ap "Can fetch IMDB results for #{@title}"
        ap e.message
        []
      end

    end

    class Filmweb < BaseSearch

      SEARCH_MOVIE_URL = "http://www.filmweb.pl/search?q=%s"

      # fetch ratings from 1st result:
      def rating
        return '' unless @results.first
        # "7,1/10" => "7.1"
        return @results.first[:rating].gsub(/\/.*/, '').gsub(',','.').to_f rescue ''
      end

      def filmweb_search_url
        URI(SEARCH_MOVIE_URL % CGI::escape(@title))
      end

      # @return [ [title, url], ... ]
      def read_results
        doc = HtmlPage.new(filmweb_search_url).document

        each_search_result(doc) do |el|
          { rating: el.content.strip }
        end
      end

      def each_search_result(document, &block)
        return unless document
        document.css(".resultsList .rateInfo strong").map do |el|
          yield(el)
        end
      end
    end
  end

  class DSL
    def self.report_for(url=nil)
      raise 'No url given!' unless url

      Report.new(url, Movie::Chomikuj).build!
    end
  end

  class CLI

    # Usage
    # bin/movies-report <URL>
    def self.run(url)
      $MOVIES_REPORT_DEBUG = true
      MoviesReport::DSL.report_for(url)
    end
  end
end
