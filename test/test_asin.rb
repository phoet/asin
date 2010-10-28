require 'test_helper'

ANY_ASIN = '1430218150'

class TestAsin < Test::Unit::TestCase

  def setup
    @helper = Object.new
    @helper.extend ASIN
  end

  def test_lookup_with_configured_asin
    secret = ENV['ASIN_SECRET']
    key = ENV['ASIN_KEY']
    puts "configure #{secret} and #{key} for this test"
    
    @helper.configure :secret => secret, :key => key
    p item = @helper.lookup(ANY_ASIN)
    assert_match(/Learn Objective/, item.title)
  end
  
  def test_configure_second_time_wont_get_overridden
    config = @helper.configure :something => 'wont get overridden'
    assert_not_nil(config[:something])

    config = @helper.configure :different => 'is also set'
    assert_not_nil(config[:something])
    assert_not_nil(config[:different])
  end
  
  def test_error_with_not_called_configure
    assert_raise(RuntimeError) { @helper.lookup ANY_ASIN }
  end

end