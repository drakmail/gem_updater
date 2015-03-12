Gem::Specification.new do |s|
  s.name        = 'gem_updater'
  s.version     = '0.0.1'
  s.date        = '2015-02-15'
  s.summary     = "Update your gems and find their changelogs"
  s.description = "It updates the gems of your Gemfile and fetches the links pointing to where their changelogs are"
  s.authors     = [ "Maxime Demolin" ]
  s.email       = 'akbarova.armia@gmail.com'
  s.files       = Dir["{lib}/**/*"]
  s.homepage    = 'https://github.com/MaximeD/gem_updater'
  s.license     = 'MIT'

  s.add_runtime_dependency 'bundler',   '~> 1.7'
  s.add_runtime_dependency 'json',      '~> 1.8'
  s.add_runtime_dependency 'nokogiri',  '~> 1.6'

  s.add_development_dependency 'rspec'

  s.executables << 'gem_update'
end
