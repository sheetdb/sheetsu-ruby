require 'simplecov'

SimpleCov.start do
  add_group "lib", "lib"
  add_filter "/spec"
end

require 'sheetsu'
require 'webmock/rspec'
