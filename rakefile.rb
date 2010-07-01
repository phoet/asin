task :test do
  require 'rake/testtask'
  Rake::TestTask.new do |t|
    t.libs << "test"
    t.ruby_opts << "-rubygems"
    t.test_files = FileList['test/test_*.rb']
    t.verbose = true
  end
end
task :default=>:test