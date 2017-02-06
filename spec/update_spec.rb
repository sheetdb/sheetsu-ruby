require "spec_helper"

describe Sheetsu do
  subject { Sheetsu::Client.new("api_url") }
  let(:spreadsheet) do
    [
      { "id" => "1", "name" => "Peter", "score" => "43" },
      { "id" => "2", "name" => "Lois", "score" => "89" },
      { "id" => "3", "name" => "Meg", "score" => "10" },
      { "id" => "4", "name" => "Chris", "score" => "43" },
      { "id" => "5", "name" => "Stewie", "score" => "72" }
    ]
  end
  let(:column) { "name" }
  let(:value) { "Stewie" }
  let(:row) do
    { "id" => "5", "name" => "Glenn", "score" => "69" }
  end
  let!(:put_stub) do
    stub_request(:put, "https://sheetsu.com/apis/v1.0/api_url/#{column}/#{value}").
      with(
        headers: { 'Accept' => 'application/vnd.sheetsu.3+json', 'Accept-Encoding' => 'gzip, deflate', 'Content-Type'=>'application/json', 'User-Agent'=>'Sheetsu-Ruby/0.1.0' },
        body: row.to_json
      ).
      to_return(
        status: 200,
        body: [row].to_json,
      )
  end
  let!(:put_stub_to_worksheet) do
    stub_request(:put, "https://sheetsu.com/apis/v1.0/api_url/sheets/Sheet1/#{column}/#{value}").
      with(
        headers: { 'Accept' => 'application/vnd.sheetsu.3+json', 'Accept-Encoding' => 'gzip, deflate', 'Content-Type'=>'application/json', 'User-Agent'=>'Sheetsu-Ruby/0.1.0' },
        body: row.to_json
      ).
      to_return(
        status: 200,
        body: [row].to_json,
      )
  end
  let!(:put_stub_not_full) do
    stub_request(:put, "https://sheetsu.com/apis/v1.0/api_url/#{column}/#{value}").
      with(
        headers: { 'Accept' => 'application/vnd.sheetsu.3+json', 'Accept-Encoding' => 'gzip, deflate', 'Content-Type'=>'application/json', 'User-Agent'=>'Sheetsu-Ruby/0.1.0' },
        body: { "name" => "Glenn" }.to_json
      ).
      to_return(
        status: 200,
        body: [{ "id" => "", "name" => "Glenn", "score" => "" }].to_json,
      )
  end
  let!(:put_stub_non_existent_column) do
    stub_request(:put, "https://sheetsu.com/apis/v1.0/api_url/foo/bar").
      with(
        headers: { 'Accept' => 'application/vnd.sheetsu.3+json', 'Accept-Encoding' => 'gzip, deflate', 'Content-Type'=>'application/json', 'User-Agent'=>'Sheetsu-Ruby/0.1.0' },
        body: row.to_json
      ).
      to_return(
        status: 404
      )
  end

  let!(:patch_stub) do
    stub_request(:patch, "https://sheetsu.com/apis/v1.0/api_url/#{column}/#{value}").
      with(
        headers: { 'Accept' => 'application/vnd.sheetsu.3+json', 'Accept-Encoding' => 'gzip, deflate', 'Content-Type'=>'application/json', 'User-Agent'=>'Sheetsu-Ruby/0.1.0' },
        body: { "name" => "Glenn" }.to_json
      ).
      to_return(
        status: 200,
        body: [{ "name" => "Glenn" }].to_json,
      )
  end
  let!(:patch_stub_to_worksheet) do
    stub_request(:patch, "https://sheetsu.com/apis/v1.0/api_url/sheets/Sheet1/#{column}/#{value}").
      with(
        headers: { 'Accept' => 'application/vnd.sheetsu.3+json', 'Accept-Encoding' => 'gzip, deflate', 'Content-Type'=>'application/json', 'User-Agent'=>'Sheetsu-Ruby/0.1.0' },
        body: row.to_json
      ).
      to_return(
        status: 200,
        body: [row].to_json,
      )
  end
  let!(:patch_stub_non_existent_column) do
    stub_request(:patch, "https://sheetsu.com/apis/v1.0/api_url/foo/bar").
      with(
        headers: { 'Accept' => 'application/vnd.sheetsu.3+json', 'Accept-Encoding' => 'gzip, deflate', 'Content-Type'=>'application/json', 'User-Agent'=>'Sheetsu-Ruby/0.1.0' },
        body: row.to_json
      ).
      to_return(
        status: 404
      )
  end

  let!(:put_stub_with_basic_auth) do
    stub_request(:put, "https://sheetsu.com/apis/v1.0/api_url/#{column}/#{value}").
      with(
        headers: { 'Accept' => 'application/vnd.sheetsu.3+json', 'Accept-Encoding' => 'gzip, deflate', 'Content-Type'=>'application/json', 'User-Agent'=>'Sheetsu-Ruby/0.1.0', 'Authorization'=>'Basic YXBpX2tleTphcGlfc2VjcmV0' },
        body: row.to_json
      ).
      to_return(
        status: 200,
        body: row.to_json
      )
  end
  let!(:non_existent_stub) do
    stub_request(:put, "https://sheetsu.com/apis/v1.0/non_existent_api/name/Stewie").
      to_return(:status => 404)
  end
  let!(:not_permited_api) do
    stub_request(:put, "https://sheetsu.com/apis/v1.0/not_permited_api/name/Stewie").
      to_return(:status => 403)
  end
  let!(:exceed_limit) do
    stub_request(:put, "https://sheetsu.com/apis/v1.0/exceed_limit/name/Stewie").
      to_return(:status => 429)
  end
  let!(:unathorized) do
    stub_request(:put, "https://sheetsu.com/apis/v1.0/api_url/name/Stewie").
      with(basic_auth: ['wrong', 'bad']).
      to_return(status: 401)
  end


  context "API exists" do
    context "limit is not exceed" do
      context "can send updates to API" do
        describe "#update" do
          it "should send PUT request to the Sheetsu API" do
            subject.update(column, value, row, true)
            expect(put_stub).to have_been_requested
          end

          it "should sent PUT request to the worksheet" do
            subject.update(column, value, row, true, "Sheet1")
            expect(put_stub_to_worksheet).to have_been_requested
          end

          context "should return updated row" do
            it "whole if whole row provided" do
              expect(subject.update(column, value, row, true)).to eq([row])
            end

            it "only updated field if not whole row provided" do
              expect(subject.update(column, value, { "name" => "Glenn" }, true)).to eq([{ "id" => "", "name" => "Glenn", "score" => "" }])
            end

            it "should raise NotFoundError if column doesn't exist" do
              expect { subject.update("foo", "bar", row, true) }.to raise_error(Sheetsu::NotFoundError)
            end
          end
        end

        describe "#update, update_whole = false" do
          it "should send PATCH request to the Sheetsu API" do
            subject.update(column, value, { "name" => "Glenn" }, false)
            expect(patch_stub).to have_been_requested
          end

          it "should sent PATCH request to the worksheet" do
            subject.update(column, value, row, false, "Sheet1")
            expect(patch_stub_to_worksheet).to have_been_requested
          end


          it "should return updated row" do
            expect(subject.update(column, value, { "name" => "Glenn" }, false)).to eq([{ "name" => "Glenn" }])
          end

          it "should raise NotFoundError if column doesn't exist" do
            expect { subject.update("foo", "bar", row, false) }.to raise_error(Sheetsu::NotFoundError)
          end
        end
      end
    end

    context "limit is exceed" do
      it "should raise LimitExceedError" do
        client = Sheetsu::Client.new("exceed_limit")
        expect { client.update(column, value, row, true) }.to raise_error(Sheetsu::LimitExceedError)
      end
    end

    context "cannot write to API" do
      it "should raise NotPermittedError" do
        client = Sheetsu::Client.new("not_permited_api")
        expect { client.update(column, value, row, true) }.to raise_error(Sheetsu::ForbiddenError)
      end
    end

    context "need authorization" do
      it "has valid credentials" do
        client = Sheetsu::Client.new("api_url", api_key: "api_key", api_secret: "api_secret")
        client.update(column, value, row, true)

        expect(put_stub_with_basic_auth).to have_been_requested
      end

      context "doesn't have valid credentials" do
        it "should raise UnauthorizedError" do
          client = Sheetsu::Client.new("api_url", api_key: "wrong", api_secret: "bad")
          expect { client.update(column, value, row, true) }.to raise_error(Sheetsu::UnauthorizedError)
        end
      end
    end
  end

  context "API doesn't exist" do
    describe "#update" do
      it "should raise NotFoundError" do
        client = Sheetsu::Client.new("non_existent_api")
        expect { client.update(column, value, row, true) }.to raise_error(Sheetsu::NotFoundError)
      end
    end
  end
end
