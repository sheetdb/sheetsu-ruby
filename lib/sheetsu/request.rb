module Sheetsu
  class Request
    
    def initialize(url, basic_auth)
      @url = url
      @basic_auth = basic_auth
    end

    def call(method, body=nil)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = request(method)
      request = add_headers(request)
      request = add_basic_auth(request)
      request = add_body(request, body)

      http.request(request)
    end

    private

      def uri
        @uri ||= URI.parse(
          Sheetsu::Util.append_query_string_to_url(@url, @options)
        )
      end

      def request(method)
        request = http_klass(method).new(uri.request_uri)
        add_headers(request)

        request
      end

      def add_headers(request)
        Sheetsu::Util.default_headers.each_pair { |k,v| request[k] = v }
        request
      end

      def add_basic_auth(request)
        if @basic_auth.keys.any?
          request.basic_auth(CGI.unescape(@basic_auth[:api_key]), CGI.unescape(@basic_auth[:api_secret]))
        end
        request
      end

      def add_body(request, body)
        if body
          request.body = body.to_json
        end
        request
      end

      def http_klass(method)
        case method
        when :get   then Net::HTTP::Get
        when :post  then Net::HTTP::Post
        when :put   then Net::HTTP::Put
        when :patch then Net::HTTP::Patch
        end
      end

      def parse_response(response)
        Sheetsu::Util.parse_response(response)
      end

  end
end
