# frozen_string_literal: true

# rbs_inline: enabled

class LeakProfiler
  class MemoryUsage
    attr_reader :thread

    # @rbs output_dir: String
    # @rbs interval: Integer
    # @rbs filename: String
    def initialize(output_dir:, interval:, filename: nil)
      @output_dir = output_dir
      @interval = interval
      @filename = filename || "memory-usage-#{Process.pid}.csv"
    end

    def report
      @thread = Thread.start do
        i = 0
        File.open(File.expand_path(File.join(@output_dir, @filename)), 'w') do |f|
          f.puts('elapsed [sec],memory usage (rss) [MB]')

          loop do
            rss = LeakProfiler::MemoryUsage.max_rss / 1024.0
            f.puts("#{i},#{rss}")
            f.fsync
            i += @interval
            sleep(@interval)
          end
        end
      end
    end
  end
end
