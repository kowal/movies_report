# coding: utf-8

module MoviesReport

  module Strategy

    class Base

      # @return [Array<Hash>]
      def run(movies)
        movies.map do |movie|
          { title: movie[:title] }.merge(movie_stats(movie[:title]))
        end
      end

      def movie_stats(title)
        results = { ratings: {} }
        MoviesReport.services.each do |service_key, service|
          # FilmDB.register_service :imdb, ::Service::IMDB
          # results[:ratings][:imdb] = [String|Hash]
          results[:ratings][service_key] = each_film(title, service, service_key)
        end
        results
      end
    end

  end

end