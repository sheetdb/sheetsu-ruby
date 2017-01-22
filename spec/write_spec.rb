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
  let(:one_row) do
    { id: 6, name: "Glenn", score: 69 }
  end
  let(:multiple_rows) do
    [
      { id: 6, name: "Glenn", score: 69 },
      { id: 7, name: "Joe", score: 44 },
      { id: 8, name: "Cleaveland", score: 33 }
    ]
  end
  let!(:post_stub) do
    stub_request(:post, "https://sheetsu.com/apis/v1.0/api_url").
      with(
        headers: { 'Accept' => 'application/vnd.sheetsu.3+json', 'Accept-Encoding' => 'gzip, deflate', 'Content-Type'=>'application/json', 'User-Agent'=>'Sheetsu-Ruby/0.1.0' },
        body: [one_row].to_json
      ).
      to_return(
        status: 201,
        body: one_row.to_json,
      )
  end
  let!(:post_stub_multiple_rows) do
    stub_request(:post, "https://sheetsu.com/apis/v1.0/api_url").
      with(
        headers: { 'Accept' => 'application/vnd.sheetsu.3+json', 'Accept-Encoding' => 'gzip, deflate', 'Content-Type'=>'application/json', 'User-Agent'=>'Sheetsu-Ruby/0.1.0' },
        body: multiple_rows.to_json
      ).
      to_return(
        status: 201,
        body: multiple_rows.to_json,
      )
  end


  context "API exists" do
    context "limit is not exceed" do
      context "can write to API" do
        describe "#write" do
          it "should send POST request to the Sheetsu API with one row" do
            subject.write(one_row)
            expect(post_stub).to have_been_requested
          end

          it "should send POST request to the Sheetsu API with multiple rows" do
            subject.write(multiple_rows)
            expect(post_stub_multiple_rows).to have_been_requested
          end

          # it "should return array with created rows" do
          #   expect(subject.read).to eq(spreadsheet)
          # end

          # it "should send request with options" do
          #   subject.read(limit: 1, offset: 2)
          #   expect(get_stub_with_params).to have_been_requested
          # end
        end
      end
    end


CHECK WHAT IS RETURNED FROM API WHEN MULTIPLE ROWS ARE CREATED
CHECK IF IT'S POSSIBLE TO SEND ARRAY OF ROWS, WITHOUT ROWS HASH (PROBABLY NOT, OR IS A BAD PRACTICE)

  #   context "limit is exceed" do
  #     it "should raise LimitExceedError" do
  #       client = Sheetsu::Client.new("exceed_limit")
  #       expect { client.read }.to raise_error(Sheetsu::LimitExceedError)
  #     end
  #   end

  #   context "cannot write to API" do
  #     it "should raise NotPermittedError" do
  #       client = Sheetsu::Client.new("not_permited_api")
  #       expect { client.read }.to raise_error(Sheetsu::ForbiddenError)
  #     end
  #   end

  #   context "need authorization" do
  #     it "has valid credentials" do
  #       client = Sheetsu::Client.new("api_url", api_key: "api_key", api_secret: "api_secret")
  #       client.read

  #       expect(get_stub_with_basic_auth).to have_been_requested
  #     end

  #     context "doesn't have valid credentials" do
  #       it "should raise UnauthorizedError" do
  #         client = Sheetsu::Client.new("api_url", api_key: "wrong", api_secret: "bad")
  #         expect { client.read }.to raise_error(Sheetsu::UnauthorizedError)
  #       end
  #     end
  #   end
  # end

  # context "API doesn't exist" do
  #   describe "#read" do
  #     it "should raise APINotFoundError" do
  #       client = Sheetsu::Client.new("non_existent_api")
  #       expect { client.read }.to raise_error(Sheetsu::APINotFoundError)
  #     end
  #   end
  end
end
