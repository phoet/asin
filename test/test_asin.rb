require 'test_helper'

class TestWhichRuby < Test::Unit::TestCase
  
  def setup
    @helper = Object.new
    @helper.extend ASIN
  end

  # comment in and add your key to test real calls
  def test_r_type_from_engine
    p item = @helper.lookup('1430218150', :AWSAccessKeyId => 'AKIAJFA5X7RTOKFNPVZQ')
    assert_match(/Learn Objective/, item.title)
  end

end