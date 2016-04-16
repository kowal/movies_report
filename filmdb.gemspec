# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'rake'
require 'filmdb/version'

Gem::Specification.new do |gem|
  gem.name          = "filmdb"
  gem.version       = FilmDb::VERSION
  gem.platform      = Gem::Platform::CURRENT
  gem.authors       = ["Marek Kowalcze"]
  gem.email         = ["marek.kowalcze@gmail.com"]
  gem.description   = %q{Film Database.}
  gem.summary       = %q{Film DB. API & CLI for building movies reports based on multiple sources.}
  gem.homepage      = "https://github.com/kowal/filmdb"
  gem.license       = 'MIT'

  gem.files         = FileList['lib/**/*.rb', 'bin/*'].to_a
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "nokogiri", ">= 1.3.3"
  gem.add_dependency "imdb", "0.8.2"
  gem.add_dependency "awesome_print", "1.1.0"
  gem.add_dependency "terminal-table", "1.4.5"
  gem.add_dependency "redis", "3.2.1"
  gem.add_dependency "sidekiq", "3.3.4"
  gem.add_dependency "sidekiq-status", "0.5.3"
  gem.add_dependency "ruby-progressbar", "1.7.5"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rspec-collection_matchers"
  gem.add_development_dependency "rspec-legacy_formatters"
  gem.add_development_dependency "guard-rspec"
  gem.add_development_dependency "libnotify"
  gem.add_development_dependency "mocha"
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "coveralls"
  gem.add_development_dependency "vcr"
  gem.add_development_dependency "webmock", ["< 1.14"]
  gem.add_development_dependency "fakeredis"
  gem.add_development_dependency "syntax"
  gem.add_development_dependency "rack"
  gem.add_development_dependency "sinatra"
  gem.add_development_dependency "slim"
  gem.add_development_dependency "metric_fu"
  gem.add_development_dependency "yard"
  gem.add_development_dependency "yield"
  gem.add_development_dependency "foreman"
end