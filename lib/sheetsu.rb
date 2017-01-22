require 'sheetsu/read'
require 'sheetsu/write'
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

    def write(data)
      if data.is_a?(Hash)
        Sheetsu::Write.new(@api_url, @http_basic_auth).row(data)
      elsif data.is_a?(Array)
        Sheetsu::Write.new(@api_url, @http_basic_auth).rows(data)
      end
    end
  end
end
