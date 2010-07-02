require 'test_helper'

class TestAsin < Test::Unit::TestCase
  
  def setup
    @helper = Object.new
    @helper.extend ASIN
  end

  # comment in and add your key to test real calls
  def test_r_type_from_engine
    @helper.configure :secret => '4w5ApABP2dALi4/8bdqm9xIcZ8GPe0P0PnocXNTB', :key => 'AKIAJFA5X7RTOKFNPVZQ'
    p item = @helper.lookup('1430218150')
    assert_match(/Learn Objective/, item.title)
  end

end