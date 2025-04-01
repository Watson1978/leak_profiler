# frozen_string_literal: true

require 'objspace'

class LeakProfiler
  class Allocations
    def initialize(logger:, interval:, max_allocations:, max_referrers:)
      @logger = logger
      @interval = interval
      @max_allocations = max_allocations
      @max_referrers = max_referrers
    end

    def report
      Thread.start do
        loop do
          allocations = {}

          ObjectSpace.trace_object_allocations_start
          sleep(@interval)
          ObjectSpace.trace_object_allocations_stop

          ObjectSpace.each_object.each do |obj|
            key = allocated_location(obj)
            next unless key

            allocations[key] ||= {}
            allocations[key][:metrics] ||= Hash.new { |h, k| h[k] = 0 }
            allocations[key][:metrics][:count] += 1
            allocations[key][:metrics][:bytes] += ObjectSpace.memsize_of(obj)

            allocations[key][:sample_object] = obj
          end

          report_allocations(allocations)
          report_referrer_objects(allocations)
        end
      end
    end

    private

    def report_allocations(allocations)
      return if @max_allocations <= 0

      @logger.add(Logger::Severity::INFO, "Allocations #{"=" * 80}")
      sort(allocations).take(@max_allocations).each do |key, value|
        @logger.add(Logger::Severity::INFO, "#{key} retains #{value[:metrics][:bytes]} bytes, allocations #{value[:metrics][:count]} objects")
      end
    end

    def report_referrer_objects(allocations)
      return if @max_referrers <= 0

      @logger.add(Logger::Severity::INFO, "Referrers #{"-" * 80}")
      sort(allocations).take(@max_referrers).each do |key, value|
        referrer_objects = detect_referrer_objects(value[:sample_object])

        logs = referrer_objects.map do |r|
          "    #{r[:referrer_object].class} (allocated at #{r[:referrer_object_allocated_line]})"
        end

        @logger.add(Logger::Severity::INFO, "#{key} object is referred at:")
        logs.uniq.each do |log|
          @logger.add(Logger::Severity::INFO, log)
        end
      end
    end

    def detect_referrer_objects(object)
      referrer_objects = []
      ObjectSpace.each_object.each do |obj|
        r = ObjectSpace.reachable_objects_from(obj)
        begin
          if r&.include?(object)
            key = allocated_location(obj)
            next unless key

            referrer_objects << { referrer_object: obj, referrer_object_allocated_line: key }
          end
        rescue StandardError
        end
      end
      referrer_objects
    end

    def allocated_location(obj)
      return unless ObjectSpace.allocation_sourcefile(obj)

      "#{ObjectSpace.allocation_sourcefile(obj)}:#{ObjectSpace.allocation_sourceline(obj)}"
    end

    def sort(allocations)
      allocations.sort_by { |_, v| -v[:metrics][:bytes] }
    end
  end
end
