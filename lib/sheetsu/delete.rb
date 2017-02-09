module Sheetsu
  class Delete < Sheetsu::Request

    def rows(options)
      add_options_to_url(options)

      response = call(:delete)
      parse_response(response)
    end

  end
end
