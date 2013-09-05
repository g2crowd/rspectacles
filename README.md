# RSpectacles

RSpectacles is an in-browser visualizer and profiler for RSpec. It uses server
sent events, redis, and d3.js to render a
[partition](http://bl.ocks.org/mbostock/4063423) of your specs in real time, so
that you can tell at a glance where the time is spent in your test suite.

As a Sinatra app it can be run standalone, or else mounted on another Rack app.

## Installation

    gem install rspectacles

Or in your Gemfile:

    group :test, :development do
      gem 'rspectacles'
    end

Then add the formatter to your .rspec file:

    --require 'rspectacles/redis_formatter'
    --format RSpectacles::RedisFormatter

    --format progress # or whatever other formatters you want to use

RSpectacles depends on [redis](http://redis.io) for pubsub and persistence. You
can quickly get an instance up and running by using your favorite package
manager:

    brew install redis
    redis-server

Start the server and connect to it in your browser:

    rspectacles

Then run your specs and watch the magic happen!

## The Server

The server can be run in standalone mode:

    rspectacles

Or mounted directly on your app:

    # routes.rb
    mount RSpectacles::App => '/rspectacles'

## Realtime Results

RSpectacles will attempt to stream spec results into the browser in realtime.
This optional feature depends on EventMachine, and so will only work on servers
with EM support. So if you mount RSpectacles on an app that uses
[thin](http://code.macournoyer.com/thin/) or
[rainbows](http://rainbows.rubyforge.org/) then
you should be able to see the realtime results.

If you use a server that doesn't support EventMachine - no sweat. You'll still
be able to see the visualization. You'll just need to refresh your browser
from time to time.

Or you could always spin up an instance in standalone mode, which uses thin by
default.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
