require 'sheetsu/read'
require 'sheetsu/Util'

module Sheetsu
  class Client

    def initialize(api_url, auth_credentials={})
      @api_url = Sheetsu::Util.parse_api_url(api_url)
      @http_basic_auth = auth_credentials
    end

    def read(options={})
      Sheetsu::Read.new(@api_url, @http_basic_auth).rows(options)
    end
  end
end
