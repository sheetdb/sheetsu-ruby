require 'sheetsu/util'
require 'sheetsu/errors'
require 'sheetsu/request'

require 'json'

module Sheetsu
  class Read < Sheetsu::Request

    def rows(options={})
      add_options_to_url(options)

      response = call(:get)
      parse_response(response)
    end

  end
end
