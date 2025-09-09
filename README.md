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

LeakProfiler.new.report.report_rss

# ... your code that may have memory leaks ...
```

### `LeakProfiler.new`
* Arguments:
  * `output_dir` (default `./leak_profiler`): Specify the output directory for report.

### `LeakProfiler#report`
This method outputs where the object was allocated and where it is referenced, like:

```
Allocations ================================================================================
/home/watson/src/fluentd/lib/fluent/plugin_helper/thread.rb:70 retains 1098464 bytes, allocations 165 objects
/home/watson/src/fluentd/lib/fluent/plugin/metrics_local.rb:58 retains 56400 bytes, allocations 50 objects
/home/watson/.rbenv/versions/3.4.2/lib/ruby/3.4.0/open3.rb:534 retains 50080 bytes, allocations 544 objects
/home/watson/src/fluentd/lib/fluent/msgpack_factory.rb:105 retains 44400 bytes, allocations 50 objects
/home/watson/.rbenv/versions/3.4.2/lib/ruby/site_ruby/3.4.0/rubygems/specification.rb:1093 retains 43846 bytes, allocations 409 objects
/home/watson/src/fluentd/lib/fluent/plugin.rb:181 retains 40960 bytes, allocations 23 objects
/home/watson/src/fluentd/lib/fluent/msgpack_factory.rb:99 retains 36000 bytes, allocations 200 objects
/home/watson/.rbenv/versions/3.4.2/lib/ruby/3.4.0/open3.rb:535 retains 29400 bytes, allocations 49 objects
/home/watson/.rbenv/versions/3.4.2/lib/ruby/gems/3.4.0/gems/csv-3.3.3/lib/csv/writer.rb:154 retains 26820 bytes, allocations 56 objects
/home/watson/.rbenv/versions/3.4.2/lib/ruby/gems/3.4.0/gems/csv-3.3.3/lib/csv.rb:2983 retains 26560 bytes, allocations 61 objects
Referrers --------------------------------------------------------------------------------
/home/watson/src/fluentd/lib/fluent/plugin_helper/thread.rb:70 object is referred at:
    Fiber (allocated at /home/watson/src/fluentd/lib/fluent/plugin/metrics_local.rb:58)
    NameError::message (allocated at /home/watson/.rbenv/versions/3.4.2/lib/ruby/3.4.0/open3.rb:534)
    NoMethodError (allocated at /home/watson/.rbenv/versions/3.4.2/lib/ruby/3.4.0/open3.rb:534)
    Fluent::PluginHelper::ChildProcess::ProcessInfo (allocated at /home/watson/src/fluentd/lib/fluent/plugin_helper/child_process.rb:355)
    Hash (allocated at /home/watson/src/fluentd/lib/fluent/plugin/formatter_csv.rb:55)
...
```

**Allocations**: This section lists the locations in the code where object was allocated, along with the size of the allocation and the number of objects allocated.

**Referrers**: This section lists the locations in the code where the object is referenced.

* Arguments:
  * `interval` (default `30`): The interval in seconds for report.
  * `max_allocations` (default `10`): Outputs the specified number of objects that use a lot of memory.
  * `max_referrers` (default `3`): Outputs the number of references in order of the amount of memory used.
  * `max_sample_objects` (default `100`): Sampling objects to detect referrer.
  * `logger` (defalut `nil`): Specify the logger object if you want to use custom logger.
  * `filename` (defalut `nil`): Specify the filename if you want to use custom filename.

> [!WARNING]
> This uses `ObjectSpace.allocation_sourcefile` method to measurement.
> It can't get an object allocated information in Ruby core API / C extension library API.

### `LeakProfiler#report_rss`
This method outputs the RSS (Resident Set Size) of the process with CSV format, like:

```
elapsed [sec],memory usage (rss) [MB]
0,47.20703125
1,53.40234375
2,55.02734375
3,55.90234375
```

* Arguments:
  * `interval` (default `1`): The interval in seconds for report.
  * `filename` (defalut `nil`): Specify the filename if you want to use custom filename.

### `LeakProfiler#report_memsize`
This method outputs `ObjectSpace.memsize_of_all` values with CSV format, like:

```
elapsed [sec],ObjectSpace.memsize_of_all values [MB]
0,11.435378074645996
1,12.78317642211914
2,11.785511016845703
3,11.785999298095703
4,11.786487579345703
```

* Arguments:
  * `interval` (default `1`): The interval in seconds for report.
  * `filename` (defalut `nil`): Specify the filename if you want to use custom filename.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Watson1978/leak_profiler.
