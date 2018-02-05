module Sheetsu
  class Destroy < Sheetsu::Request

    def rows(params, options)
      add_options_to_url(options)

      response = call(:delete, params)
      parse_response(response)
    end
  end
end
