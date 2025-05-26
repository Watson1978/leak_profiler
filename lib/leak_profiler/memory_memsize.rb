# frozen_string_literal: true

# rbs_inline: enabled

require 'objspace'

class LeakProfiler
  class MemoryMemsize
    attr_reader :thread

    # @rbs output_dir: String
    # @rbs interval: Integer
    # @rbs filename: String
    def initialize(output_dir:, interval:, filename: nil)
      @output_dir = output_dir
      @interval = interval
      @filename = filename || "memory-memsize-#{Process.pid}.csv"
    end

    def report
      @thread = Thread.start do
        i = 0
        File.open(File.expand_path(File.join(@output_dir, @filename)), 'w') do |f|
          f.puts('elapsed [sec],ObjectSpace.memsize_of_all values [MB]')

          loop do
            memsize = Float(ObjectSpace.memsize_of_all) / (1024 * 1024)
            f.puts("#{i},#{memsize}")
            f.fsync
            i += @interval
            sleep(@interval)
          end
        end
      end
    end
  end
end
