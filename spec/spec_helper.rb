require 'simplecov'
require 'sheetsu'
require 'webmock/rspec'

SimpleCov.start do
  add_group "lib", "lib"
  add_filter "/spec"
end
