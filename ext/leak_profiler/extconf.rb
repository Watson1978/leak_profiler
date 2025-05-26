# frozen_string_literal: true

require 'mkmf'

$LDFLAGS += ' -lpsapi' if RUBY_PLATFORM.include?('mingw')

create_makefile('leak_profiler_ext')
