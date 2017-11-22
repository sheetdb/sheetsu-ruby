require "spec_helper"

describe Sheetsu do
  let!(:error_500) do
    stub_request(:get, "https://sheetsu.com/apis/v1.0or/api_url_500")
      .to_return(status: 500)
  end

  it "has a version number" do
    expect(Sheetsu::VERSION).to match /\d+\.\d+\.\d+/
  end

  context "Server returns 5xx error" do
    it "should throw generic SheetsuError" do
      client = Sheetsu::Client.new("api_url_500")
      expect { client.read }.to raise_error(Sheetsu::SheetsuError)
    end
  end
end
