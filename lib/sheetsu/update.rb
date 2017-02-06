require 'sheetsu/util'
require 'sheetsu/errors'
require 'sheetsu/request'

require 'json'

module Sheetsu
  class Update < Sheetsu::Request

    def put(options)
      add_column_value_to_url(options)

      response = call(:put, options[:data])
      parse_response(response)
    end

    def patch(options)
      add_column_value_to_url(options)

      response = call(:patch, options[:data])
      parse_response(response)
    end

    private

      def add_sheet_to_url
        if @options[:sheet]
          @url += ['/sheets/', CGI::escape(@options[:sheet]).to_s].join('')

          @options.delete(:sheet)
        end
      end

  end
end
