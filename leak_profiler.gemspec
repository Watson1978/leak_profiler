# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'leak_profiler'
  spec.version = '0.7.1'
  spec.authors = ['Watson']
  spec.email = ['watson1978@gmail.com']
  spec.license = 'MIT'

  spec.summary = 'A simple profiler for Ruby to detect memory leak.'
  spec.description = 'A simple profiler for Ruby to detect memory leak.'
  spec.homepage = 'https://github.com/Watson1978/leak_profiler'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/Watson1978/leak_profiler'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[.git .github Gemfile Steepfile])
    end
  end
  spec.require_paths = ['lib']
  spec.extensions << 'ext/leak_profiler/extconf.rb'

  spec.add_dependency('logger', '~> 1.7')
end
