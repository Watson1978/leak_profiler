# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/extensiontask'
require 'rake/testtask'

task default: %i[compile test]

Rake::ExtensionTask.new('leak_profiler_ext') do |ext|
  ext.ext_dir = 'ext/leak_profiler'
end

Rake::TestTask.new do |task|
  task.pattern = 'test/test_*.rb'
end

desc 'Update RBS signature'
task :'rbs:update' do
  sh 'bundle exec rbs-inline --output lib'
end
