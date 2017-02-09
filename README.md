# sheetsu-ruby
Ruby bindings for the Sheetsu API (https://sheetsu.com/docs).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sheetsu-ruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sheetsu-ruby

## Usage

### Generating a Client

You need to create a new Sheetsu::Client object, and populate it with your Sheetsu API URL. You can find this URL on [Sheetsu Dashboard](https://sheetsu.com/your-apis).

```ruby
# Create new client object
client = Sheetsu::Client.new("https://sheetsu.com/apis/v1.0/020b2c0f")
```
or
```ruby
# Create new client object
client = Sheetsu::Client.new("020b2c0f")
```

If you have HTTP Basic Authentication turned on for your API, you should pass `api_key` and `api_secret` here, like:
```ruby
# Create new client object with HTTP Basic Auth keys
client = Sheetsu::Client.new("020b2c0f", api_key: "YOUR_API_KEY", api_secret: "YOUR_API_SECRET")
```

### CRUD

Sheetsu gives you the ability to use full CRUD on your Google Spreadsheet. Remember to populate the first row of every sheet with column names. You can look at [example spreadsheet](https://docs.google.com/spreadsheets/d/1WTwXrh2ZDXmXATZlQIuapdv4ldyhJGZg7LX8GlzPdZw/edit?usp=sharing).

### Create
[Link to docs](https://sheetsu.com/docs#post)

To add data to Google Spreadsheets, send a hash or an array of hashes.
```ruby
# Adds single row
client.create({ id: 7, name: "Glenn", score: "69" })

# Adds bunch of rows
rows = [
  { id: 7, name: "Glenn", score: "69" },
  { id: 8, name: "Brian", score: "77" },
  { id: 9, name: "Joe", score: "45" }
]
client.create(rows)
```

By default, all writes are performed on the first sheet (worksheet). Pass name of a sheet as a 2nd param to add data to other worksheet.
```ruby
# Adds single row to worksheet named "Sheet3"
client.create({ "foo" => "bar", "baz" => "quux" }, "Sheet3")
```

On success returns a hash or an array of hashes with created values. On error check [errors](#errors).

### Read
[Link to docs](https://sheetsu.com/docs#get)

Read the whole sheet
```ruby
client.read
```

You can pass hash with options
  - `sheet` - get data from named worksheet
  - `limit` - limit number of results
  - `offset` - start from N first record
  - `search` - hash with search params [(more below)](#search)

```ruby
# Get first two rows from worksheet named "Sheet2"
client.read(sheet: "Sheet2", limit: 2)

# Get 5th record from worksheet named "Sheet3"
client.read(
  offset: 4, # because rows are numbered from 0
  limit: 1,  # because only one row
  sheet: "Sheet3"
)
```

#### search
[Link to docs](https://sheetsu.com/docs#get_search)

To get rows that match search criteria, pass a hash with search params

```ruby
# Get all rows where column 'id' is 'foo' and column 'value' is 'bar'
client.read(search: { id: "foo", value: "bar" })

# Get all rows where column 'First name' is 'Peter' and column 'Score' is '42'
client.read(search: { "First name" => "Peter", "Score" => 42 })

# Get first two row where column 'First name' is 'Peter',
# column 'Score' is '42' from sheet named "Sheet3"
client.read(
  search: { "First name" => "Peter", "Score" => 42 } # search criteria
  limit: 2        # first two rows
  sheet: "Sheet3" # Sheet name
)
```

On success returns an array of hashes. On error check [errors](#errors).

### Update
[Link to docs](https://sheetsu.com/docs#patch)

To update row(s), pass column name and its value which is used to find row(s).

```ruby
# Update all columns where 'name' is 'Peter' to have 'score' = 99 and 'last name' = 'Griffin'
client.update(
  "name", # column name
  "Peter", # value to search for
  { "score": 99, "last name" => "Griffin" }, # hash with updates
)
```

By default, [PATCH request](https://sheetsu.com/docs#patch) is sent, which is updating only values which are in the hash passed to the method. To send [PUT request](https://sheetsu.com/docs#put), pass 4th argument being `true`. [Read more about the difference between PUT and PATCH in our docs](https://sheetsu.com/docs#patch).


```ruby
# Update all columns where 'name' is 'Peter' to have 'score' = 99 and 'last name' = 'Griffin'
# Empty all cells which matching, which are not 'score' or 'last name'
client.update(
  "name", # column name
  "Peter", # value to search for
  { "score": 99, "last name" => "Griffin" }, # hash with updates
  true # nullify all fields not passed in the hash above
)
```

To perform `#update` on different than the first sheet, pass sheet name as a 5th argument.
```ruby
# Update all columns where 'name' is 'Peter' to have 'score' = 99 and 'last name' = 'Griffin'
# In sheet named 'Sheet3'
# Empty all cells which matching, which are not 'score' or 'last name'
client.update(
  "name", # column name
  "Peter", # value to search for
  { "score": 99, "last name" => "Griffin" }, # hash with updates
  true, # nullify all fields not passed in the hash above
  "Sheet3"
)
```

On success returns an array of hashes with updated values. On error check [errors](#errors).

### Delete
[Link to docs](https://sheetsu.com/docs#delete)

To delete row(s), pass column name and its value which is used to find row(s).

```ruby
# Delete all rows where 'name' equals 'Peter'
client.delete(
  "name", # column name
  "Peter" # value to search for
)
```

You can pass sheet name as a 3rd argument. All operations are performed on the first sheet, by default.
```ruby
# Delete all rows where 'foo' equals 'bar' in sheet 'Sheet3'
client.delete(
  "foo",   # column name
  "bar",   # value to search for
  "Sheet3" # sheet name
)
```

If success returns `:ok` symbol. If error check [errors](#errors).

### Errors
There are different styles of error handling. We choose to throw exceptions and signal failure loudly. You do not need to deal with any HTTP responses from the API calls directly. All exceptions are matching particular response code from Sheetsu API. You can [read more about it here](https://sheetsu.com/docs#statuses).

All exceptions are a subclass of `Sheetsu::SheetsuError`. The list of different error subclasses is listed below. You can choose to rescue each of them or rescue just the parent class (`Sheetsu::SheetsuError`).


```ruby
Sheetsu::NotFoundError
Sheetsu::ForbiddenError
Sheetsu::LimitExceedError
Sheetsu::UnauthorizedError
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

Run all tests:
```
rspec
```

Run a single test:
```
rspec spec/read_spec.rb
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sheetsu/sheetsu-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

### Pull Requests

- **Add tests!** Your patch won't be accepted if it doesn't have tests.

- **Create topic branches**. Please, always create a branch with meaningful name. Don't ask us to pull from your master branch.

- **One pull request per feature**. If you want to do more than one thing, please send
  multiple pull requests.

- **Send coherent history**. Make sure each individual commit in your pull
  request is meaningful. If you had to make multiple intermediate commits while
  developing, please squash them before sending them to us.

### Docs

[Sheetsu documentation sits on GitHub](https://github.com/sheetsu/docs). We would love your contributions! We want to make these docs accessible and easy to understand for everyone. Please send us Pull Requests or open issues on GitHub.

# To do 
1. Allow passing whole API URLs as well as just slugs to the client, like:
```ruby
client = Sheetsu::Client.new("https://sheetsu.com/apis/v1.0/020b2c0f")
# should be the same as
client = Sheetsu::Client.new("020b2c0f")
```
