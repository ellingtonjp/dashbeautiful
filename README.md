# Dashbeautiful

Beautiful interface Meraki's wonderful Dashboard API. API calls are cached for fast access.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dashbeautiful'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dashbeautiful

## Usage

```ruby
require 'dashbeautiful'

KEY = 'my-awesome-api-key'

# Get all organizations that KEY has access to, and find one by name
organizations = Dashbeautiful::Organization.all api_key: KEY
dunder = organizations.find { |org| org.name == 'Dunder Mifflin Paper Co.' }

# Find a network and get all its devices
scranton = dunder.networks.find_by(:name, 'Scranton, PA')
device_list = scranton.devices

# Calls against the API are cached, so subsequent calls are fast
schrute_farms = dunder.networks.find_by(:name, 'Schrute Farms')  # fast, 'networks' returns cached result

# You can force API access with a bang
schrute_farms = dunder.networks!.find_by(:id, '123456')  # slow, 'networks!' makes api call
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ellingtonjp/dashbeautiful. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Dashbeautiful project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ellingtonjp/dashbeautiful/blob/master/CODE_OF_CONDUCT.md).
