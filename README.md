[![Gem Version](https://badge.fury.io/rb/rspectacles.png)](http://badge.fury.io/rb/rspectacles)
# RSpectacles

RSpectacles is an in-browser visualizer and profiler for RSpec. It uses d3.js to render a
[partition](http://bl.ocks.org/mbostock/4063423) of your specs based on time to complete, so
that you can tell at a glance where the time is spent in your test suite.

![Example Partition](viz.png)

As a Sinatra app it can be run standalone, or else mounted on another Rack app.

## Installation

    gem install rspectacles

Or in your Gemfile:

    group :test, :development do
      gem 'rspectacles'
    end

Then add the formatter to your .rspec file:

    --require rspectacles/formatter/batched
    --format RSpectacles::Formatter::Batched

    --format progress # or whatever other formatters you want to use

The formatter assumes you are using RSpec3. If you use RSpec 2:

    --require rspectacles/formatter/legacy/base
    --format RSpectacles::Formatter::Legacy::Base

## Batched Formatter

The `Batched` formatter is preferred, as it will send fewer web requests and will be less likely to
slow down your specs if the connection to the server is slow. You can change the batch
sizes by changing the `batch_size` in config settings.

## Storage

RSpectacles depends on ActiveRecord for persistence. You
can quickly get an instance up and running by configuring the database.yml file,
and running the standard rake commands:

    rake db:create
    rake db:migrate

Start the server and connect to it in your browser:

    rspectacles

Then run your specs and watch the magic happen!

## Web Server

The server can be run in standalone mode:

    rspectacles

Or mounted directly on your app:

    # routes.rb
    mount RSpectacles::App => '/rspectacles'

## Configuration
If you need to change any settings, the best method is to create a yaml file
with your settings, and set the ```RSPECTACLES_CONFIG``` environment variable so
that both the server and formatter can locate the file.

For instance:

```sh
export RSPECTACLES_CONFIG='/path/to/config/rspectacles.yml'
```

And in ```rspectacles.yml```:
```yaml
sinatra_port: 4567
batch_size: 500
rspectacles_url: 'http://127.0.0.1:4567/'
last_run_primary_key: 'redis-rspec-last-run'
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
