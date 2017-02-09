 # coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sheetsu/version'

Gem::Specification.new do |spec|
  spec.name          = "sheetsu-ruby"
  spec.version       = Sheetsu::VERSION
  spec.authors       = ["Michael Oblak"]
  spec.email         = ["m@sheetsu.com"]

  spec.summary       = %q{Turn Google Spreadsheets into REST APIs}
  spec.description   = %q{Official Sheetsu API wrapper (https://sheetsu.com/docs). Sheetsu allows you to automate Google Spreadsheets and use them as a resource in a REST API. It is easier than using standard Google Spreadsheets API because Sheetsu handles all the 'dirty' work for you.}
  spec.homepage      = "https://sheetsu.com"

  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "webmock", "~> 2.3"
  spec.add_development_dependency "pry", "~> 0"
  spec.add_development_dependency "simplecov", "~> 0.11.1"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 1.0.0"
end
