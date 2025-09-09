# frozen_string_literal: true

# rbs_inline: enabled

require 'objspace'
require 'set'

class LeakProfiler
  class Allocations
    UNKNOWN = '<unknown>:<unknown>'
    private_constant :UNKNOWN

    attr_reader :thread

    # @rbs logger: untyped
    # @rbs interval: Integer
    # @rbs max_allocations: Integer
    # @rbs max_referrers: Integer
    def initialize(logger:, interval:, max_allocations:, max_referrers:, max_sample_objects:)
      @logger = logger
      @interval = interval
      @max_allocations = max_allocations
      @max_referrers = max_referrers
      @max_sample_objects = max_sample_objects
    end

    def report
      @thread = Thread.start do
        loop do
          ObjectSpace.trace_object_allocations_start
          sleep(@interval)
          ObjectSpace.trace_object_allocations_stop

          allocations = Hash.new { |h, k| h[k] = {} }
          allocations_by_class = Hash.new { |h, k| h[k] = 0 }

          ObjectSpace.each_object.each do |obj|
            begin
              klass = obj_class(obj)
              allocations_by_class[klass] += ObjectSpace.memsize_of(obj)
            rescue StandardError
            end

            key = allocated_location(obj)
            allocations[key][:metrics] ||= Hash.new { |h, k| h[k] = 0 }
            allocations[key][:metrics][:count] += 1
            allocations[key][:metrics][:bytes] += ObjectSpace.memsize_of(obj)

            allocations[key][:sample_objects] ||= []
            allocations[key][:sample_objects] << obj
          end

          allocations.each_value do |v|
            v[:sample_objects] = v[:sample_objects].sample(@max_sample_objects)
          end

          report_allocations_class(allocations_by_class)
          report_allocations(allocations)
          report_referrer_objects(allocations)

          allocations.each_value(&:clear)
          allocations.clear
          allocations_by_class.clear
        rescue StandardError => e
          @logger.add(Logger::Severity::ERROR, "Error occurred: #{e.message}, backtrace: #{e.backtrace.join("\n")}")
        end
      end
    end

    private

    def report_allocations_class(allocations_by_class)
      return if @max_allocations <= 0

      @logger.add(Logger::Severity::INFO, "Allocations by class #{"~" * 80}")
      allocations_by_class.sort_by { |_, v| -v }
                          .take(@max_allocations).each do |klass, value|
        @logger.add(Logger::Severity::INFO, "#{klass} retains #{value} bytes")
      end
    end

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

      objs = allocations.reject { |k, _| k == UNKNOWN }
      sort(objs).take(@max_referrers).each do |key, value|
        referrer_objects = detect_referrer_objects(value[:sample_objects])

        logs = referrer_objects.map do |r|
          klass = obj_class(r[:referrer_object])
          "    #{klass} (allocated at #{r[:referrer_object_allocated_line]})"
        end

        @logger.add(Logger::Severity::INFO, "#{key} object is referred at:")
        logs.uniq.each do |log|
          @logger.add(Logger::Severity::INFO, log)
        end
      end
    end

    def detect_referrer_objects(objects)
      referrer_objects = []
      objects_ids = objects.to_set(&:object_id)

      ObjectSpace.each_object.each do |obj|
        r = ObjectSpace.reachable_objects_from(obj)
        begin
          if r&.any? { |o| objects_ids.include?(o.object_id) }
            key = allocated_location(obj)
            referrer_objects << { referrer_object: obj, referrer_object_allocated_line: key }
          end
        rescue StandardError
        end
      end
      referrer_objects
    end

    def allocated_location(obj)
      file = ObjectSpace.allocation_sourcefile(obj)
      return UNKNOWN if file.nil? || file.empty?

      line = ObjectSpace.allocation_sourceline(obj)

      "#{file}:#{line}"
    end

    def sort(allocations)
      allocations.sort_by { |_, v| -v[:metrics][:bytes] }
    end

    def obj_class(obj)
      obj.respond_to?(:class) ? obj.class : BasicObject
    end
  end
end
