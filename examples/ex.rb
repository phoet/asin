# $:.unshift File.join(File.dirname(__FILE__),'..','lib')
# 
# require 'which_ruby'
# 
# include WhichRuby
# 
# puts "running on #{ruby_type} #{ruby_description}"
# %w{jruby ruby rubinius}.each do |ru|
#   puts "checking #{ru}?"
#   check = send(:"#{ru}?")
#   puts "  #{ru} is #{check}"
#   puts "  with version #{ruby_version}" if check
#   ruby_scope(ru){puts "  running in scope"}
# end