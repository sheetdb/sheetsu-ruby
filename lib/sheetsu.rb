require 'sheetsu/create'
require 'sheetsu/read'
require 'sheetsu/update'
require 'sheetsu/delete'
require 'sheetsu/util'

module Sheetsu
  class Client

    def initialize(api_url, auth_credentials={})
      @api_url = Sheetsu::Util.parse_api_url(api_url)
      @http_basic_auth = auth_credentials
    end

    def create(data, sheet=nil)
      if data.is_a?(Hash)
        Sheetsu::Create.new(@api_url, @http_basic_auth).row(data, { sheet: sheet })
      elsif data.is_a?(Array)
        Sheetsu::Create.new(@api_url, @http_basic_auth).rows(data, { sheet: sheet })
      end 
    end

    def read(options={})
      Sheetsu::Read.new(@api_url, @http_basic_auth).rows(options)
    end

    def update(column, value, data, update_whole=false, sheet=nil)
      options = { column: column, value: value, data: data, update_whole: update_whole, sheet: sheet }

      if update_whole
        Sheetsu::Update.new(@api_url, @http_basic_auth).put(options)
      else
        Sheetsu::Update.new(@api_url, @http_basic_auth).patch(options)
      end
    end

    def delete(column, value, sheet=nil)
      options = { column: column, value: value, sheet: sheet }

      Sheetsu::Delete.new(@api_url, @http_basic_auth).rows(options)
    end

  end
end
