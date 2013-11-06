# coding: utf-8

require 'timeout'

module MoviesReport

  module Cli

    class Progressbar

      attr_reader :result, :progressbar

      def initialize(timeout_in_seconds)
        @timeout_in_seconds = timeout_in_seconds
        @progressbar = nil
        @result = nil
        @pending_jobs = true
      end

      def for_each_step(&block)
        while @pending_jobs
          begin
            Timeout::timeout(@timeout_in_seconds) do
              @result = block.call
              update_progressbar(@result)
            end
          rescue Timeout::Error
            next
          end
        end
      end

      def update_progressbar(result)
        unless result[:status]
          return
        else
          started = result[:status][:started]
          finished = result[:status][:finished]

          @pending_jobs = started.to_i > 0
          if @pending_jobs
            @progressbar ||= create_progressbar(started + finished)
            valid_data = result.values[1..-1]
            if valid_data
              sparks_values = valid_data.map { |v| v.nan? ? 5 : 10 }
            end
            @progressbar.format "%t [%c/%C] |%B| %p% #{sparks(sparks_values)}"
            @progressbar.progress = finished
          end
        end
      end

      def create_progressbar(total)
        @progressbar = ProgressBar.create({
          :title => "[FilmDB] Fetching stats",
          :starting_at => 0,
          :total => total,
          :length => 100
        })
      end

      # Sparks visualizaiton
      # Taken from https://gist.github.com/jcromartie/1367091
      #
      def sparks(values)
        @ticks = %w[▁ ▂ ▃ ▄ ▅ ▆ ▇]
        values = values.map { |x| x.to_f }
        min, range, scale = values.min, values.max - values.min, @ticks.length - 1
        if !(range == 0)
          values.map { |x| @ticks[(((x - min) / range) * scale).round] }.join
        else
          values.map { |x| @ticks[1] }.join
        end
      end

    end
  end
end
