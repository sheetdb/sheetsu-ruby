require 'sheetsu/util'
require 'sheetsu/errors'
require 'sheetsu/request'

require 'json'

module Sheetsu
  class Read < Sheetsu::Request

    def rows(options={})
      @options = options
      
      add_options_to_url(options)

      response = call(:get)
      parse_response(response)
    end

    private

      def add_options_to_url(options)
        add_sheet_to_url
        add_column_value_to_url(options)
        add_search_values_to_url
      end

      def add_sheet_to_url
        if @options[:sheet]
          @url += ['/sheets/', CGI::escape(@options[:sheet]).to_s].join('')

          @options.delete(:sheet)
        end
      end

      def add_search_values_to_url
        if @options[:search]
          @url += '/search'
          @options[:search].each_pair { |key, value| @options[key] = value }
          @options.delete(:search)
        end
      end

  end
end
