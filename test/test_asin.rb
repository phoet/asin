require 'test_helper'

class TestAsin < Test::Unit::TestCase
  
  def setup
    @helper = Object.new
    @helper.extend ASIN
  end

  # comment in and add your key to test real calls
  def test_r_type_from_engine
    p item = @helper.lookup('1430218150', :AWSAccessKeyId => 'AKIAJFA5X7RTOKFNPVZQ', :ResponseGroup => :Medium)
    assert_match(/Learn Objective/, item.title)
  end

end