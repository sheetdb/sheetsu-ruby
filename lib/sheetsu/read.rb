require 'sheetsu/util'
require 'sheetsu/errors'
require 'sheetsu/request'

require 'json'
require 'net/https'

require 'pry'

module Sheetsu
  class Read < Sheetsu::Request

    def rows(options={})
      @options = options

      response = call(:get)
      parse_response(response)
    end

    private

      def parse_response(response)
        case response.code.to_i
        when 200 then JSON.parse(response.body)
        when 401 then raise Sheetsu::UnauthorizedError
        when 403 then raise Sheetsu::ForbiddenError
        when 404 then raise Sheetsu::APINotFoundError
        when 429 then raise Sheetsu::LimitExceedError
        else
          raise Sheetsu::SheetsuError.new(nil, response.code, response.body)
        end
      end

  end
end
