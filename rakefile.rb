require "bundler"
require "rake/rdoctask"
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["--format Fuubar", "--color", "-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/**/*_spec.rb'
end

Rake::RDocTask.new(:rdoc_dev) do |rd|
  rd.rdoc_files.include(File.readlines('.document').map(&:strip))
  rd.options + ['-a', '--line-numbers', '--charset=UTF-8']
end

task :default=>:spec
