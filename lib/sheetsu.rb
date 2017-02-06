require 'sheetsu/read'
require 'sheetsu/write'
require 'sheetsu/update'
require 'sheetsu/delete'
require 'sheetsu/util'

module Sheetsu
  class Client

    def initialize(api_url, auth_credentials={})
      @api_url = Sheetsu::Util.parse_api_url(api_url)
      @http_basic_auth = auth_credentials
    end

    def read(options={})
      Sheetsu::Read.new(@api_url, @http_basic_auth).rows(options)
    end

    def write(*options)
      if options.is_a?(Hash)
        _write(options)
      else
        _write({ data: options[0], sheet: options[1] })
      end
    end

    def update(*options)
      if options.is_a?(Hash)
        _update(options)
      else
        _update({ column: options[0], value: options[1], data: options[2], update_whole: options[3] ? true : false, sheet: options[4] })
      end
    end

    def delete(*options)
      if options.is_a?(Hash)
        _delete(options)
      else
        _delete({ column: options[0], value: options[1], sheet: options[2] })
      end
    end

    private
      def _write(options)
        if options[:data].is_a?(Hash)
          Sheetsu::Write.new(@api_url, @http_basic_auth).row(options[:data], { sheet: options[:sheet] })
        elsif options[:data].is_a?(Array)
          Sheetsu::Write.new(@api_url, @http_basic_auth).rows(options[:data], { sheet: options[:sheet] })
        end
      end

      def _update(options)
        if ([:column, :value, :data] & options.keys).size == [:column, :value, :data].size
          if options[:update_whole]
            Sheetsu::Update.new(@api_url, @http_basic_auth).put(options)
          else
            Sheetsu::Update.new(@api_url, @http_basic_auth).patch(options)
          end
        else
          raise Sheetsu::NotEnoughParametersError
        end
      end

      def _delete(options)
        if ([:column, :value] & options.keys).size == [:column, :value].size
          Sheetsu::Delete.new(@api_url, @http_basic_auth).rows(options)
        else
          raise Sheetsu::NotEnoughParametersError
        end
      end

  end
end
