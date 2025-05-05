# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

task default: :test

Rake::TestTask.new do |task|
  task.pattern = 'test/test_*.rb'
end

# Update RBS signature
task :'rbs:update' do
  sh 'bundle exec rbs-inline --output lib'
end
