$:.push File.expand_path("../lib", __FILE__)

require 'bean_sprout/version'

Gem::Specification.new do |s|
  s.name        = 'bean_sprout'
  s.version     = BeanSprout::VERSION
  s.date        = '2015-12-10'
  s.summary     = "Exchanging book-keeping information made easy."
  s.description = "Bean Sprout is a library that provides a set of data " +
    "structures to support extraction and exchanging of general book-keeping " +
    "information between different systems."
  s.authors     = ["Liqing Muyi"]
  s.email       = 'muyiliqing@gmail.com'

  s.files       = Dir["lib/**/*", "Rakefile", "Gemfile", "MIT-LICENSE", "README.md"]

  s.required_ruby_version = '>= 2.0.0'

  s.add_development_dependency 'rake', '~> 12', '>= 12.3.0'
  s.add_development_dependency 'minitest', '~> 5.8', '>= 5.8.1'

  s.homepage    = 'http://github.com/muyiliqing/bean_sprout'
  s.license     = 'MIT'
end
