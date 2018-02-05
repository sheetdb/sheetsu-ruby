require "spec_helper"

describe Sheetsu do
  subject { Sheetsu::Client.new("https://sheetsu.com/apis/v1.0or/api_url") }
  let!(:headers) do
    { 'Accept' => 'application/vnd.sheetsu.3+json', 'Accept-Encoding' => 'gzip, deflate', 'Content-Type'=>'application/json', 'User-Agent'=>"Sheetsu-Ruby/#{Sheetsu::VERSION}" }
  end
  let(:spreadsheet) do
    [
      { "id" => "1", "name" => "Peter", "score" => "43" },
      { "id" => "2", "name" => "Lois", "score" => "89" },
      { "id" => "3", "name" => "Meg", "score" => "10" },
      { "id" => "4", "name" => "Chris", "score" => "43" },
      { "id" => "5", "name" => "Stewie", "score" => "72" }
    ]
  end
  let(:params) { { name: "Stewie" } }
  let!(:delete_stub) do
    stub_request(:delete, "https://sheetsu.com/apis/v1.0or/api_url")
      .with(headers: headers, body: params.to_json)
      .to_return(status: 200, body: spreadsheet.last.to_json)
  end
  let!(:delete_sheet_stub) do
    stub_request(:delete, "https://sheetsu.com/apis/v1.0or/api_url/sheets/Sheet1")
      .with(headers: headers, body: params.to_json)
      .to_return(status: 200, body: spreadsheet.last.to_json)
  end
  let!(:delete_with_basic_auth_stub) do
    stub_request(:delete, "https://sheetsu.com/apis/v1.0or/api_url")
      .with(headers: headers.merge({ 'Authorization'=>'Basic YXBpX2tleTphcGlfc2VjcmV0' }), body: params.to_json)
      .to_return(status: 200, body: spreadsheet.last.to_json)
  end
  let!(:delete_to_non_existent_column_stub) do
    stub_request(:delete, "https://sheetsu.com/apis/v1.0or/api_url")
      .with(headers: headers, body: { foo: "bar" }.to_json)
      .to_return(status: 404)
  end
  let!(:non_existent_stub) do
    stub_request(:delete, "https://sheetsu.com/apis/v1.0or/non_existent_api")
      .with(body: params.to_json)
      .to_return(:status => 404)
  end
  let!(:not_permited_api) do
    stub_request(:delete, "https://sheetsu.com/apis/v1.0or/not_permited_api")
      .with(body: params.to_json)
      .to_return(:status => 403)
  end
  let!(:exceed_limit) do
    stub_request(:delete, "https://sheetsu.com/apis/v1.0or/exceed_limit")
      .with(body: params.to_json)
      .to_return(:status => 429)
  end
  let!(:unathorized) do
    stub_request(:delete, "https://sheetsu.com/apis/v1.0or/api_url")
      .with(basic_auth: ['wrong', 'bad'], body: params.to_json)
      .to_return(status: 401)
  end

  context "API exists" do
    context "limit is not exceed" do
      context "can delete from API" do
        describe "#destroy" do
          it "should send DELETE request to the Sheetsu API" do
            subject.destroy(params)
            expect(delete_stub).to have_been_requested
          end

          it "should send DELETE request to the worksheet" do
            subject.destroy(params, "Sheet1")
            expect(delete_sheet_stub).to have_been_requested
          end

          it "should return :ok" do
            expect(subject.destroy(params)).to eq(spreadsheet.last)
          end

          describe "column doesn't exist" do
            it "should raise NotFoundError" do
              expect { subject.destroy({ foo: "bar" }) }.to raise_error(Sheetsu::NotFoundError)
            end
          end
        end
      end
    end

    context "limit is exceed" do
      it "should raise LimitExceedError" do
        client = Sheetsu::Client.new("exceed_limit")
        expect { client.destroy(params) }.to raise_error(Sheetsu::LimitExceedError)
      end
    end

    context "cannot write to API" do
      it "should raise NotPermittedError" do
        client = Sheetsu::Client.new("not_permited_api")
        expect { client.destroy(params) }.to raise_error(Sheetsu::ForbiddenError)
      end
    end

    context "need authorization" do
      it "has valid credentials" do
        client = Sheetsu::Client.new("api_url", api_key: "api_key", api_secret: "api_secret")
        client.destroy(params)

        expect(delete_with_basic_auth_stub).to have_been_requested
      end

      context "doesn't have valid credentials" do
        it "should raise UnauthorizedError" do
          client = Sheetsu::Client.new("api_url", api_key: "wrong", api_secret: "bad")
          expect { client.destroy(params) }.to raise_error(Sheetsu::UnauthorizedError)
        end
      end
    end
  end

  context "API doesn't exist" do
    describe "#destroy" do
      it "should raise NotFoundError" do
        client = Sheetsu::Client.new("non_existent_api")
        expect { client.destroy(params) }.to raise_error(Sheetsu::NotFoundError)
      end
    end
  end
end
