# frozen_string_literal: true

D = Steep::Diagnostic

target :leak_profiler do
  signature 'sig'

  check 'lib'
  check 'test'

  configure_code_diagnostics(D::Ruby.lenient)
end
