lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'elasticrecord/version'

Gem::Specification.new do |spec|
  spec.add_development_dependency 'bundler', '~> 1.0'
  spec.authors = ['Roee Sheelo']
  spec.description = 'An ActiveRecord-like DSL for ElasticSearch'
  spec.email = %w[roee.sheelo@gmail.com]
  spec.files = %w[CHANGELOG.md LICENSE.md README.md LICENSE elasticrecord.gemspec] + Dir['lib/**/*.rb']
  spec.homepage = 'https://github.com/communit-team/elasticrecord'
  spec.licenses = %w["GNU GENERAL PUBLIC LICENSE"]
  spec.name = 'elatsicrecord'
  spec.require_paths = %w[lib]
  spec.required_ruby_version = '>= 2.3.1'
  spec.summary = spec.description
  spec.version = ElasticRecord::Version
end
