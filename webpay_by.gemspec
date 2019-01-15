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

  s.add_dependency 'rails', '~> 4'
end
