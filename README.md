# LeakProfiler

This is a Ruby gem for profiling memory leaks in Ruby applications.
It provides tools to help identify and analyze memory usage patterns, making it easier to find and fix memory leaks.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add leak_profiler
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install leak_profiler
```

## Usage

```ruby
require 'leak_profiler'

LeakProfiler.new.report.report_memory_usage

# ... your code that may have memory leaks ...
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Watson1978/leak_profiler.
