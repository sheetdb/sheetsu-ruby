require 'sheetsu/util'
require 'sheetsu/errors'
require 'sheetsu/request'

require 'json'

module Sheetsu
  class Write < Sheetsu::Request

    def row(row, options={})
      response = call(:post, row)
      parse_response(response)
    end

    def rows(rows, options={})
      response = call(:post, { rows: rows })
      parse_response(response)
    end

    private

      def add_options_to_url
        add_sheet_to_url
        add_column_value_to_url
        add_search_values_to_url
      end

      def add_sheet_to_url
        if @options[:sheet]
          @url += ['/sheets/', CGI::escape(@options[:sheet]).to_s].join('')

          @options.delete(:sheet)
        end
      end

      def add_column_value_to_url
        if @options[:column] && @options[:value]
          @url += encoded_column(@options)
          
          @options.delete(:column)
          @options.delete(:value)
        end
      end

      def add_search_values_to_url
        if @options[:search]
          @url += '/search'
          @options[:search].each_pair { |key, value| @options[key] = value }
          @options.delete(:search)
        end
      end

      def encoded_column(options)
        ['/', CGI::escape(options[:column]), '/', CGI::escape(options[:value])].join('')
      end

  end
end
