require 'sheetsu/version'

module Sheetsu
  module Util

    @sheetsu_api_url = "https://sheetsu.com/apis/v1.0/"

    def self.default_headers
      {
        'Accept-Encoding' => 'gzip, deflate',
        'Accept' => 'application/vnd.sheetsu.3+json',
        'Content-Type' => 'application/json',
        'User-Agent' => "Sheetsu-Ruby/#{Sheetsu::VERSION}"
      }
    end

    def self.parse_api_url(url)
      [@sheetsu_api_url, url].join('')
    end

    def self.append_query_string_to_url(url, options)
      if options
        url + "?#{query_string(options)}"
      else
        url
      end
    end

    def self.encoded_column(options)
      ['/', CGI::escape(options[:column]), '/', CGI::escape(options[:value])].join('')
    end

    def self.parse_response(response)
      case response.code.to_i
      when 200 then JSON.parse(response.body)
      when 201 then JSON.parse(response.body)
      when 204 then :ok
      when 401 then raise Sheetsu::UnauthorizedError
      when 403 then raise Sheetsu::ForbiddenError
      when 404 then raise Sheetsu::NotFoundError
      when 429 then raise Sheetsu::LimitExceedError
      else
        raise Sheetsu::SheetsuError.new(nil, response.code, response.body)
      end
    end

    private
      def self.query_string(options)
        options.map do |k,v|
          "#{k.to_s}=#{CGI::escape(v.to_s)}"
        end.join('&')
      end

  end
end
