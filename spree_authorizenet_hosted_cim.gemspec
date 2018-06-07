# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_authorizenet_hosted_cim'
  s.version     = '3.1.0'
  s.summary     = 'Integrates the Authorize.net hosted CIM form into the Spree checkout process'
  s.description = 'Integrates the Authorize.net hosted CIM form into the Spree checkout process'
  s.required_ruby_version = '>= 2.1.0'

  s.author    = 'Jake Bell'
  s.email     = 'jbbell@umn.edu'
  s.homepage  = 'https://github.com/cehdeti/spree_authorizenet_hosted_cim'
  s.license = 'BSD-3'

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  spree_version = '>= 3.1.0', '< 4.0'
  s.add_dependency 'spree_auth_devise', spree_version
  s.add_dependency 'spree_core', spree_version
  s.add_dependency 'spree_gateway', spree_version

  s.add_development_dependency 'capybara', '~> 2.6'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl', '~> 4.5'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails', '~> 3.4'
  s.add_development_dependency 'sass-rails', '~> 5.0.0'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
end
