# frozen_string_literal: true

require 'objspace'

class LeakProfiler
  class MemoryMemsize
    attr_reader :thread

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
            i += @interval
            sleep(@interval)
          end
        end
      end
    end
  end
end
