require 'nokogiri'
require "net/http"
require "uri"
require "awesome_print"
require "imdb"

module MoviesReport

  require "movies_report/version"
  require "movies_report/config"

  require "movies_report/html_page"
  require "movies_report/search/base_search"
  require "movies_report/search/filmweb"
  require "movies_report/search/imdb"
  require "movies_report/source/chomikuj"

  require "movies_report/report"

  require "movies_report/dsl"
  require "movies_report/cli"
end

MoviesReport.configure do |config|
  config.debug = false
end
