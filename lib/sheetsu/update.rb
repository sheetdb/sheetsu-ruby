require 'sheetsu/util'
require 'sheetsu/errors'
require 'sheetsu/request'

require 'json'

module Sheetsu
  class Update < Sheetsu::Request

    def put(options)
      add_options_to_url(options)

      response = call(:put, options[:data])
      parse_response(response)
    end

    def patch(options)
      add_options_to_url(options)

      response = call(:patch, options[:data])
      parse_response(response)
    end

  end
end
