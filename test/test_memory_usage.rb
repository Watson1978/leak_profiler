# frozen_string_literal: true

require 'leak_profiler'
require 'minitest/autorun'

class MemoryUsageTest < Minitest::Test
  def test_report_rss
    assert_equal(true, LeakProfiler::MemoryUsage.max_rss.positive?)
  end
end
