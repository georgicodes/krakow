$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'krakow/version'
Gem::Specification.new do |s|
  s.name = 'nsq-krakow'
  s.version = Krakow::VERSION.version
  s.summary = 'NSQ library'
  s.author = 'Georgi Knox'
  s.email = 'georgiknox@gmail.com'
  s.homepage = 'https://github.com/georgicodes/krakow'
  s.description = 'NSQ ruby library'
  s.license = 'Apache 2.0'
  s.require_path = 'lib'
  s.add_runtime_dependency 'celluloid', '~> 0.16.0'
  s.add_runtime_dependency 'http'
  s.add_runtime_dependency 'multi_json'
  s.add_runtime_dependency 'digest-crc'
  s.add_development_dependency 'childprocess'
  s.add_development_dependency 'snappy'
  s.add_development_dependency 'minitest'
  s.files = Dir['lib/**/*'] + %w(nsq-krakow.gemspec README.md CHANGELOG.md CONTRIBUTING.md LICENSE)
  s.extra_rdoc_files = %w(CHANGELOG.md CONTRIBUTING.md LICENSE)
end
