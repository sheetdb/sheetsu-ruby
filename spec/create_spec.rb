require "spec_helper"

describe Sheetsu do
  subject { Sheetsu::Client.new("api_url") }
  let!(:headers) do
    { 'Accept' => 'application/vnd.sheetsu.3+json', 'Accept-Encoding' => 'gzip, deflate', 'Content-Type'=>'application/json', 'User-Agent'=>'Sheetsu-Ruby/0.1.0' }
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
  let(:one_row) do
    { "id" => "6", "name" => "Glenn", "score" => "69" }
  end
  let(:multiple_rows) do
    [
      { "id" => "6", "name" => "Glenn", "score" => "69" },
      { "id" => "7", "name" => "Joe", "score" => "44" },
      { "id" => "8", "name" => "Cleaveland", "score" => "33" }
    ]
  end
  let!(:post_stub) do
    stub_request(:post, "https://sheetsu.com/apis/v1.0/api_url")
      .with(headers: headers, body: one_row.to_json)
      .to_return(status: 201, body: one_row.to_json)
  end
  let!(:post_sheet_stub) do
    stub_request(:post, "https://sheetsu.com/apis/v1.0/api_url/sheets/Sheet1")
      .with(headers: headers, body: one_row.to_json)
      .to_return(status: 201, body: one_row.to_json)
  end
  let!(:post_multiple_rows_stub) do
    stub_request(:post, "https://sheetsu.com/apis/v1.0/api_url")
      .with(headers: headers, body: { rows: multiple_rows }.to_json)
      .to_return(status: 201, body: multiple_rows.to_json)
  end
  let!(:post_sheet_multiple_rows_stub) do
    stub_request(:post, "https://sheetsu.com/apis/v1.0/api_url/sheets/Sheet1")
      .with(headers: headers, body: { rows: multiple_rows }.to_json)
      .to_return(status: 201, body: multiple_rows.to_json)
  end

  let!(:post_stub_with_basic_auth) do
    stub_request(:post, "https://sheetsu.com/apis/v1.0/api_url")
      .with(headers: headers.merge({ 'Authorization'=>'Basic YXBpX2tleTphcGlfc2VjcmV0' }), body: one_row.to_json)
      .to_return(status: 200, body: one_row.to_json)
  end

  let!(:non_existent_stub) do
    stub_request(:post, "https://sheetsu.com/apis/v1.0/non_existent_api").
      to_return(:status => 404)
  end
  let!(:not_permited_api) do
    stub_request(:post, "https://sheetsu.com/apis/v1.0/not_permited_api").
      to_return(:status => 403)
  end
  let!(:exceed_limit) do
    stub_request(:post, "https://sheetsu.com/apis/v1.0/exceed_limit").
      to_return(:status => 429)
  end
  let!(:unathorized) do
    stub_request(:post, "https://sheetsu.com/apis/v1.0/api_url").
      with(basic_auth: ['wrong', 'bad']).
      to_return(status: 401)
  end

  context "API exists" do
    context "limit is not exceed" do
      context "can write to API" do
        describe "#create" do
          it "should send POST request to the Sheetsu API with one row" do
            subject.create(one_row)
            expect(post_stub).to have_been_requested
          end

          it "should send POST request to the worksheet with one row" do
            subject.create(one_row, "Sheet1")
            expect(post_sheet_stub).to have_been_requested
          end

          it "should send POST request to the Sheetsu API with multiple rows" do
            subject.create(multiple_rows)
            expect(post_multiple_rows_stub).to have_been_requested
          end

          it "should send POST request to the worksheet with multiple rows" do
            subject.create(multiple_rows, "Sheet1")
            expect(post_sheet_multiple_rows_stub).to have_been_requested
          end

          context "should return array " do
            it "with created row" do
              expect(subject.create(one_row)).to eq(one_row)
            end

            it "with created rows" do
              expect(subject.create(multiple_rows)).to eq(multiple_rows)
            end
          end
        end
      end
    end

    context "limit is exceed" do
      it "should raise LimitExceedError" do
        client = Sheetsu::Client.new("exceed_limit")
        expect { client.create(one_row) }.to raise_error(Sheetsu::LimitExceedError)
      end
    end

    context "cannot write to API" do
      it "should raise NotPermittedError" do
        client = Sheetsu::Client.new("not_permited_api")
        expect { client.create(one_row) }.to raise_error(Sheetsu::ForbiddenError)
      end
    end

    context "need authorization" do
      it "has valid credentials" do
        client = Sheetsu::Client.new("api_url", api_key: "api_key", api_secret: "api_secret")
        client.create(one_row)

        expect(post_stub_with_basic_auth).to have_been_requested
      end

      context "doesn't have valid credentials" do
        it "should raise UnauthorizedError" do
          client = Sheetsu::Client.new("api_url", api_key: "wrong", api_secret: "bad")
          expect { client.create(one_row) }.to raise_error(Sheetsu::UnauthorizedError)
        end
      end
    end
  end

  context "API doesn't exist" do
    describe "#write" do
      it "should raise NotFoundError" do
        client = Sheetsu::Client.new("non_existent_api")
        expect { client.create(one_row) }.to raise_error(Sheetsu::NotFoundError)
      end
    end
  end
end
