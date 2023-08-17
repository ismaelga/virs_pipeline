# -*- ruby -*-

require "rubygems"
require "minitest/test_task"

$:.unshift("lib")

# named test, sensible defaults
Minitest::TestTask.create

# or more explicitly:

Minitest::TestTask.create(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.warning = false
  t.test_globs = ["test/**/*_test.rb"]
end

task(default: :test)

# vim: syntax=Ruby
