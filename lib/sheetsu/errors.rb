module Sheetsu
  class SheetsuError < StandardError
    attr_reader :message
    attr_reader :http_status
    attr_reader :http_body

    def initialize(message = nil, http_status = nil, http_body = nil)
      @message = message
      @http_status = http_status
      @http_body = http_body
    end

    def to_s
      "(Status #{@http_status}) #{@http_body}"
    end
  end

  class NotFoundError < SheetsuError
  end

  class ForbiddenError < SheetsuError
  end

  class LimitExceedError < SheetsuError
  end

  class UnauthorizedError < SheetsuError
  end

  class NotEnoughParametersError < SheetsuError
  end
end
