# Sheetsu

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

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sheetsu/sheetsu-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

s = Sheetsu.new(API_SLUG or API_URL)

s.create({foo: "bar"})
s.create([{foo: "bar"},{foo: "qvy"}])

s.read
s.read(limit: 1, offset: 2)
s.read(column: "foo", value: "bar")

s.update()

# TODO 
parse api urls or just slugs

check this 'Accept' => 'application/vnd.sheetsu.3+json',
