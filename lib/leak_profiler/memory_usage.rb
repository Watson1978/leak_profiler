# frozen_string_literal: true

class LeakProfiler
  class MemoryUsage
    attr_reader :thread

    def initialize(output_dir:, interval:, filename: nil)
      @output_dir = output_dir
      @interval = interval
      @filename = filename || "memory-usage-#{Process.pid}.csv"
    end

    def report
      raise('Not supported Windows platform because this uses `ps` command for measurement.') if /mingw/.match?(RUBY_PLATFORM)

      pid = Process.pid

      @thread = Thread.start do
        i = 0
        File.open(File.expand_path(File.join(@output_dir, @filename)), 'w') do |f|
          f.puts('elapsed [sec],memory usage (rss) [MB]')

          loop do
            rss = Integer(`ps -o rss= -p #{pid}`) / 1024.0
            f.puts("#{i},#{rss}")
            i += @interval
            sleep(@interval)
          end
        end
      end
    end
  end
end
