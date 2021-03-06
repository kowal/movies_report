# coding: utf-8

require 'filmdb/search/filmweb_service'

module FilmDb
  module Search
    # Represents movie search in Filmweb service
    #
    class Filmweb
      def initialize(title, service = FilmwebService)
        @title = title
        @result = service.find(title)
      end

      # fetch ratings from 1st result:
      def rating
        format_rating(@result[:rating])
      end

      private

      # "7,1/10" => "7.1"
      def format_rating(rating)
        Float(rating.gsub(/\/.*/, '').tr(',', '.'))
      rescue ArgumentError
        nil
      end
    end
  end
end
