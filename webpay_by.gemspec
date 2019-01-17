$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'webpay_by/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'webpay_by'
  s.version     = WebpayBy::VERSION
  s.authors     = ['Bexeiitov Nursultan']
  s.email       = ['bekseitov@mail.ru']
  s.homepage    = 'http://neoweb.kz'
  s.summary     = 'webpay.by gem'
  s.description = 'Adds the ability to work with the payment system webpay.by.'

  s.files = Dir['{app,config,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['spec/**/*']
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.3'

  s.add_dependency 'activesupport', '>= 4.1.0'
  s.add_dependency 'builder', '>= 2.0'

  s.add_development_dependency 'rspec'
end
