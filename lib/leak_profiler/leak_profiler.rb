# frozen_string_literal: true

# rbs_inline: enabled

require_relative 'allocations'
require_relative 'memory_memsize'
require_relative 'memory_usage'
require 'fileutils'
require 'logger'

class LeakProfiler
  # @rbs output_dir: String
  # @rbs return: void
  def initialize(output_dir: './leak_profiler')
    @output_dir = output_dir
    @threads = []

    FileUtils.mkdir_p(@output_dir)
  end

  # @rbs interval: Integer
  # @rbs max_allocations: Integer
  # @rbs max_referrers: Integer
  # @rbs max_sample_objects: Integer
  # @rbs logger: untyped
  # @rbs filename: String
  # @rbs return: self
  def report(interval: 30, max_allocations: 10, max_referrers: 3, max_sample_objects: 100, logger: nil, filename: nil)
    filename ||= "leak_profiler-#{Process.pid}.log"
    logger ||= Logger.new(File.join(@output_dir, filename))
    profiler = LeakProfiler::Allocations.new(logger: logger, interval: interval, max_allocations: max_allocations, max_referrers: max_referrers, max_sample_objects: max_sample_objects)
    profiler.report
    @threads << profiler.thread

    self
  end

  # @rbs interval: Integer
  # @rbs filename: String
  # @rbs return: self
  def report_rss(interval: 1, filename: nil)
    profiler = LeakProfiler::MemoryUsage.new(output_dir: @output_dir, interval: interval, filename: filename)
    profiler.report
    @threads << profiler.thread

    self
  end

  # @rbs interval: Integer
  # @rbs filename: String
  # @rbs return: self
  def report_memsize(interval: 1, filename: nil)
    profiler = LeakProfiler::MemoryMemsize.new(output_dir: @output_dir, interval: interval, filename: filename)
    profiler.report
    @threads << profiler.thread

    self
  end

  def shutdown
    @threads.each(&:kill)
    @threads.each(&:join)
  end
end
