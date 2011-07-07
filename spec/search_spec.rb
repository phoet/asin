require 'spec_helper'

module ASIN
  describe ASIN do
    before do
      ASIN::Configuration.reset
      @helper = ASIN::Client.instance
      @helper.configure :logger => nil

      @secret = ENV['ASIN_SECRET']
      @key = ENV['ASIN_KEY']
      puts "configure #{@secret} and #{@key} for this test"
    end

    context "configuration" do
      it "should fail without secret and key" do
        lambda { @helper.lookup 'bla' }.should raise_error(RuntimeError)
      end

      it "should fail with wrong configuration key" do
        lambda { @helper.configure :wrong => 'key' }.should raise_error(NoMethodError)
      end

      it "should not override the configuration" do
        config = @helper.configure :key => 'wont get overridden'
        config.key.should_not be_nil

        config = @helper.configure :secret => 'is also set'
        config.key.should_not be_nil
        config.secret.should_not be_nil
      end

      it "should work with a configuration block" do
        conf = ASIN::Configuration.configure do |config|
          config.key = 'bla'
        end
        conf.key.should eql('bla')
      end

      it "should read configuration from yml" do
        config = ASIN::Configuration.configure :yaml => 'spec/asin.yml'
        config.secret.should eql('secret_yml')
        config.key.should eql('key_yml')
        config.host.should eql('host_yml')
        config.logger.should eql('logger_yml')
      end

      it "should read configuration from yml with block" do
        conf = ASIN::Configuration.configure :yaml => 'spec/asin.yml' do |config, yml|
          config.secret = nil
          config.key = yml['secret']
        end
        conf.secret.should be_nil
        conf.key.should eql('secret_yml')
      end
    end

    context "lookup and search" do
      before do
        @helper.configure :secret => @secret, :key => @key
      end

      it "should lookup a book" do
        item = @helper.lookup(ANY_ASIN)
        item.title.should =~ /Learn Objective/
      end

      it "should have metadata" do
        item = @helper.lookup(ANY_ASIN, :ResponseGroup => :Medium)
        item.asin.should eql(ANY_ASIN)
        item.title.should =~ /Learn Objective/
        item.amount.should eql(3999)
        item.details_url.should eql('http://www.amazon.com/Learn-Objective-C-Mac-Mark-Dalrymple/dp/1430218150%3FSubscriptionId%3DAKIAJFA5X7RTOKFNPVZQ%26tag%3Dws%26linkCode%3Dxm2%26camp%3D2025%26creative%3D165953%26creativeASIN%3D1430218150')
        item.image_url.should eql('http://ecx.images-amazon.com/images/I/41kq5bDvnUL.jpg')
        item.review.should =~ /Learn Objective-C on the Macintosh/
      end

      it "should return a custom item class" do
        module TEST
          class TestItem
            attr_accessor :testo
            def initialize(hash)
              @testo = hash
            end
          end
        end
        @helper.configure :item_type => TEST::TestItem
        @helper.lookup(ANY_ASIN).testo.should_not be_nil
      end

      it "should return a raw value" do
        @helper.configure :item_type => :raw
        @helper.lookup(ANY_ASIN)['ItemAttributes']['Title'].should_not be_nil
      end

      it "should return a mash value" do
        @helper.configure :item_type => :mash
        @helper.lookup(ANY_ASIN).ItemAttributes.Title.should_not be_nil
      end

      it "should return a rash value" do
        @helper.configure :item_type => :rash
        @helper.lookup(ANY_ASIN).item_attributes.title.should_not be_nil
      end

      it "should search_keywords a book with fulltext" do
        items = @helper.search_keywords 'Learn', 'Objective-C'
        items.should have(10).things

        items.first.title.should =~ /Learn Objective/
      end

      it "should search_keywords never mind music" do
        items = @helper.search_keywords 'nirvana', 'never mind', :SearchIndex => :Music
        items.should have(9).things

        items.first.title.should =~ /Nevermind/
      end

      it "should search music" do
        items = @helper.search :SearchIndex => :Music
        items.should have(0).things
      end

      it "should search never mind music" do
        items = @helper.search :Keywords => 'nirvana', :SearchIndex => :Music
        items.should have(10).things

        items.first.title.should =~ /Nevermind/
      end
    end
  end
end
