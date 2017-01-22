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

    def self.slice_options(options)
      options.select do |k, v|
        [k, v] if allowed_options.include?(k)
      end.to_h
    end

    private
      def self.query_string(options)
        options.map do |k,v|
          "#{k.to_s}=#{CGI::escape(v.to_s)}"
        end.join('&')
      end

      def self.allowed_options
        [:limit, :offset]
      end



  end
end
