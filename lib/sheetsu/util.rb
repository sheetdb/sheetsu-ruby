module Sheetsu
  module Util

    SHEETSU_API_URL_BEGINNING = "https://sheetsu.com/apis/v1.0or/"

    def self.default_headers
      {
        'Accept-Encoding' => 'gzip, deflate',
        'Accept' => 'application/vnd.sheetsu.3+json',
        'Content-Type' => 'application/json',
        'User-Agent' => "Sheetsu-Ruby/#{Sheetsu::VERSION}"
      }
    end

    def self.parse_api_url(url)
      if url.start_with?(SHEETSU_API_URL_BEGINNING)
        url
      else
        [SHEETSU_API_URL_BEGINNING, url].join('')
      end
    end

    def self.append_query_string_to_url(url, options)
      url + "?#{query_string(options)}"
    end

    def self.encoded_column(options)
      ['/', CGI::escape(options[:column].to_s), '/', CGI::escape(options[:value].to_s)].join('')
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
          "#{k}=#{CGI::escape(v.to_s)}"
        end.join('&')
      end

  end
end
