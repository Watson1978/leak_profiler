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

release_task = Rake.application["release"]
# We use Trusted Publishing.
release_task.prerequisites.delete("build")
release_task.prerequisites.delete("release:rubygem_push")
release_task_comment = release_task.comment
if release_task_comment
  release_task.clear_comments
  release_task.comment = release_task_comment.gsub(/ and build.*$/, "")
end
