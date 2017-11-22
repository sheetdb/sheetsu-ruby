require "spec_helper"

describe Sheetsu do
  subject { Sheetsu::Client.new("https://sheetsu.com/apis/v1.0or/api_url") }
  let!(:headers) do
    { 'Accept' => 'application/vnd.sheetsu.3+json', 'Accept-Encoding' => 'gzip, deflate', 'Content-Type'=>'application/json', 'User-Agent'=>"Sheetsu-Ruby/#{Sheetsu::VERSION}" }
  end
  let!(:spreadsheet) do
    [
      { "id" => "1", "name" => "Peter", "score" => "43" },
      { "id" => "2", "name" => "Lois", "score" => "89" },
      { "id" => "3", "name" => "Meg", "score" => "10" },
      { "id" => "4", "name" => "Chris", "score" => "43" },
      { "id" => "5", "name" => "Stewie", "score" => "72" }
    ]
  end
  let!(:get_stub) do
    stub_request(:get, "https://sheetsu.com/apis/v1.0or/api_url")
      .with(headers: headers)
      .to_return(status: 200, body: spreadsheet.to_json)
  end
  let!(:get_stub_with_params) do
    stub_request(:get, "https://sheetsu.com/apis/v1.0or/api_url?limit=1&offset=2")
      .with(headers: headers)
      .to_return(status: 200, body: [{"id" => "2","name" => "Lois","score" => "89"}, {"id" => "3","name" => "Meg","score" => "10"}].to_json)
  end
  let!(:get_sheet_stub) do
    stub_request(:get, "https://sheetsu.com/apis/v1.0or/api_url/sheets/Sheet1")
      .with(headers: headers)
      .to_return(status: 200, body: [{"foo" => "bar"},{"foo" => "baz"}].to_json)
  end
  let!(:get_search_stub) do
    stub_request(:get, "https://sheetsu.com/apis/v1.0or/api_url/search?foo=bar&baz=quux")
      .with(headers: headers)
      .to_return(status: 200, body: [{"foo" => "bar","baz" => "quux","id" => "1"}, {"foo" => "bar","baz" => "quux","id" => "2"}, {"foo" => "bar","baz" => "quux","id" => "3"}].to_json)
  end
  let!(:get_search_sheet_stub_with_params) do
    stub_request(:get, "https://sheetsu.com/apis/v1.0or/api_url/sheets/Sheet1/search?foo=bar&baz=quux&limit=1&offset=2")
      .with(headers: headers)
      .to_return(status: 200, body: [{"foo" => "bar","baz" => "quux","id" => "1"}, {"foo" => "bar","baz" => "quux","id" => "2"}, {"foo" => "bar","baz" => "quux","id" => "3"}].to_json)
  end

  let!(:get_stub_with_basic_auth) do
    stub_request(:get, "https://sheetsu.com/apis/v1.0or/api_url")
      .with(headers: headers.merge({ 'Authorization'=>'Basic YXBpX2tleTphcGlfc2VjcmV0' }))
      .to_return(status: 200, body: spreadsheet.to_json)
  end

  let!(:non_existent_stub) do
    stub_request(:get, "https://sheetsu.com/apis/v1.0or/non_existent_api")
      .to_return(:status => 404)
  end
  let!(:not_permited_api) do
    stub_request(:get, "https://sheetsu.com/apis/v1.0or/not_permited_api")
      .to_return(:status => 403)
  end
  let!(:exceed_limit) do
    stub_request(:get, "https://sheetsu.com/apis/v1.0or/exceed_limit")
      .to_return(:status => 429)
  end
  let!(:unauthorized) do
    stub_request(:get, "https://sheetsu.com/apis/v1.0or/api_url")
      .with(basic_auth: ['wrong', 'bad'])
      .to_return(status: 401)
  end

  context "API exists" do
    context "limit is not exceed" do
      context "can read from API" do
        describe "#read" do
          it "should send GET request to the Sheetsu API" do
            subject.read
            expect(get_stub).to have_been_requested
          end

          it "should return array with hashes" do
            expect(subject.read).to eq(spreadsheet)
          end

          it "should send request with options" do
            subject.read(limit: 1, offset: 2)
            expect(get_stub_with_params).to have_been_requested
          end
        end

        describe "#read(sheet: sheet_name)" do
          it "should send GET request to the Sheetsu API" do
            subject.read(sheet: "Sheet1")
            expect(get_sheet_stub).to have_been_requested
          end

          it "should return array with hashes" do
            expect(subject.read(sheet: "Sheet1")).to eq([{ "foo" => "bar" }, { "foo" => "baz" }])
          end
        end

        describe "#read(search: {foo: 'bar'})" do
          it "should send GET request to the Sheetsu API" do
            subject.read(search: { foo: "bar", baz: "quux" })
            expect(get_search_stub).to have_been_requested
          end

          it "should return array with hashes" do
            expect(subject.read(search: { foo: "bar", baz: "quux" })).to eq([{ "foo" => "bar", "baz" => "quux", "id" => "1" }, { "foo" => "bar", "baz" => "quux", "id" => "2" },  { "foo" => "bar", "baz" => "quux", "id" => "3" }])
          end

          it "should send request with options" do
            subject.read(sheet: "Sheet1", search: { foo: "bar", baz: "quux" }, limit: 1, offset: 2)
            expect(get_search_sheet_stub_with_params).to have_been_requested
          end
        end
      end
    end

    context "limit is exceed" do
      it "should raise LimitExceedError" do
        client = Sheetsu::Client.new("exceed_limit")
        expect { client.read }.to raise_error(Sheetsu::LimitExceedError)
      end
    end

    context "cannot read from API" do
      it "should raise NotPermittedError" do
        client = Sheetsu::Client.new("not_permited_api")
        expect { client.read }.to raise_error(Sheetsu::ForbiddenError)
      end
    end

    context "need authorization" do
      it "has valid credentials" do
        client = Sheetsu::Client.new("api_url", api_key: "api_key", api_secret: "api_secret")
        client.read

        expect(get_stub_with_basic_auth).to have_been_requested
      end

      context "doesn't have valid credentials" do
        it "should raise UnauthorizedError" do
          client = Sheetsu::Client.new("api_url", api_key: "wrong", api_secret: "bad")
          expect { client.read }.to raise_error(Sheetsu::UnauthorizedError)
        end
      end
    end
  end

  context "API doesn't exist" do
    describe "#read" do
      it "should raise NotFoundError" do
        client = Sheetsu::Client.new("non_existent_api")
        expect { client.read }.to raise_error(Sheetsu::NotFoundError)
      end
    end
  end
end
