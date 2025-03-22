# frozen_string_literal: true

require_relative 'allocations'
require_relative 'memory_usage'
require 'fileutils'

class LeakProfiler
  def initialize(output_dir: './leak_profiler')
    @output_dir = output_dir

    FileUtils.mkdir_p(@output_dir)
  end

  def report(interval: 30, max_allocations: 10, max_referrers: 3, logger: nil)
    logger ||= Logger.new(File.join(@output_dir, "leak_profiler-#{Process.pid}.log"))
    LeakProfiler::Allocations.new(logger: logger, interval: interval, max_allocations: max_allocations, max_referrers: max_referrers).report

    self
  end

  def report_memory_usage(interval: 1)
    LeakProfiler::MemoryUsage.new(output_dir: @output_dir, interval: interval).report

    self
  end
end
