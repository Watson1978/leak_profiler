# frozen_string_literal: true

class LeakProfiler
  class MemoryUsage
    def initialize(output_dir:, interval:)
      @output_dir = output_dir
      @interval = interval
    end

    def report
      pid = Process.pid

      Thread.new do
        i = 0
        File.open(File.expand_path(File.join(@output_dir, "memory-usage-#{pid}.csv")), 'w') do |f|
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
