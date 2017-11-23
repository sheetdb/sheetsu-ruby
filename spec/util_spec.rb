require "spec_helper"

describe Sheetsu::Util do
  describe "#parse_api_url" do
    context "should return API URL" do
      it "when passed API slug" do
        expect(Sheetsu::Util.parse_api_url("deadbeef")).to eq("https://sheetsu.com/apis/v1.0or/deadbeef")
      end

      it "when passed full API URL" do
        expect(Sheetsu::Util.parse_api_url("https://sheetsu.com/apis/v1.0or/deadbeef")).to eq("https://sheetsu.com/apis/v1.0or/deadbeef")
      end
    end
  end
end
