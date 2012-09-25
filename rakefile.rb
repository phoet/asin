require "bundler"
require "rspec/core/rake_task"

Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["--format documentation", "--color"]
  t.pattern = 'spec/**/*_spec.rb'
end

task :default => :spec
