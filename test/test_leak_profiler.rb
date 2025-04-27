# frozen_string_literal: true

require 'leak_profiler'
require 'minitest/autorun'

class LeakProfilerTest < Minitest::Test
  def test_report
    output_dir = './tmp'
    profiler = LeakProfiler.new(output_dir: output_dir)

    profiler.report(interval: 1, max_allocations: 5, max_referrers: 2, filename: 'test_report.log')
    sleep(2)
    profiler.shutdown

    assert(File.exist?(File.join(output_dir, 'test_report.log')))
  end

  def test_report_rss
    output_dir = './tmp'
    profiler = LeakProfiler.new(output_dir: output_dir)

    profiler.report_rss(interval: 1, filename: 'test_report_rss.csv')
    sleep(2)
    profiler.shutdown

    assert(File.exist?(File.join(output_dir, 'test_report_rss.csv')))
  end

  def test_report_memsize
    output_dir = './tmp'
    profiler = LeakProfiler.new(output_dir: output_dir)

    profiler.report_memsize(interval: 1, filename: 'test_report_memsize.csv')
    sleep(2)
    profiler.shutdown

    assert(File.exist?(File.join(output_dir, 'test_report_memsize.csv')))
  end
end
