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
        VCR.use_cassette("bad_configuration", :match_requests_on => [:host, :path]) do
          lambda { @helper.lookup 'bla' }.should raise_error(RuntimeError)
        end
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
        VCR.use_cassette("lookup_#{ANY_ASIN}", :match_requests_on => [:host, :path]) do
          item = @helper.lookup(ANY_ASIN)
          item.title.should =~ /Learn Objective/
        end
      end

      it "should have metadata" do
        VCR.use_cassette("lookup_#{ANY_ASIN}_medium", :match_requests_on => [:host, :path]) do
          item = @helper.lookup(ANY_ASIN, :ResponseGroup => :Medium)
          item.asin.should eql(ANY_ASIN)
          item.title.should =~ /Learn Objective/
          item.amount.should eql(3999)
          item.details_url.should eql('http://www.amazon.com/Learn-Objective-C-Mac-Mark-Dalrymple/dp/1430218150%3FSubscriptionId%3DAKIAJFA5X7RTOKFNPVZQ%26tag%3Dws%26linkCode%3Dxm2%26camp%3D2025%26creative%3D165953%26creativeASIN%3D1430218150')
          item.image_url.should eql('http://ecx.images-amazon.com/images/I/41kq5bDvnUL.jpg')
          item.review.should =~ /Learn Objective-C on the Macintosh/
        end
      end

      it "should lookup multiple books" do
        VCR.use_cassette("lookup_#{MULTIPLE_ASINS.join('-')}_multiple", :match_requests_on => [:host, :path]) do
          items = @helper.lookup(MULTIPLE_ASINS)

          items[0].title.should =~ /Learn Objective/
          items[1].title.should =~ /Hunger Games/
        end
      end

      it "should return a custom item class" do
        VCR.use_cassette("lookup_#{ANY_ASIN}_item_class", :match_requests_on => [:host, :path]) do
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
      end

      it "should return a raw value" do
        VCR.use_cassette("lookup_#{ANY_ASIN}_raw", :match_requests_on => [:host, :path]) do
          @helper.configure :item_type => :raw
          @helper.lookup(ANY_ASIN)['ItemAttributes']['Title'].should_not be_nil
        end
      end

      it "should return a mash value" do
        VCR.use_cassette("lookup_#{ANY_ASIN}_mash", :match_requests_on => [:host, :path]) do
          @helper.configure :item_type => :mash
          @helper.lookup(ANY_ASIN).ItemAttributes.Title.should_not be_nil
        end
      end

      it "should return a rash value" do
        VCR.use_cassette("lookup_#{ANY_ASIN}_rash", :match_requests_on => [:host, :path]) do
          @helper.configure :item_type => :rash
          @helper.lookup(ANY_ASIN).item_attributes.title.should_not be_nil
        end
      end
      
      it "should search_keywords and handle a single result" do
        VCR.use_cassette("search_keywords_single_result", :match_requests_on => [:host, :path]) do
          items = @helper.search_keywords('0471317519')
          items.first.title.should =~ /A Self-Teaching Guide/
        end
      end

      it "should search_keywords a book with fulltext" do
        VCR.use_cassette("search_keywords", :match_requests_on => [:host, :path]) do
          items = @helper.search_keywords 'Learn', 'Objective-C'
          items.should have(10).things
          items.first.title.should =~ /Learn Objective/
        end
      end

      it "should search_keywords never mind music" do
        VCR.use_cassette("search_keywords_index_music", :match_requests_on => [:host, :path]) do
          items = @helper.search_keywords 'nirvana', 'never mind', :SearchIndex => :Music
          items.should have(10).things
          items.first.title.should =~ /Nevermind/
        end
      end

      it "should search music" do
        VCR.use_cassette("search_index_music", :match_requests_on => [:host, :path]) do
          items = @helper.search :SearchIndex => :Music
          items.should have(0).things
        end
      end

      it "should search never mind music" do
        VCR.use_cassette("search_keywords_key_index_music", :match_requests_on => [:host, :path]) do
          items = @helper.search :Keywords => 'nirvana', :SearchIndex => :Music
          items.should have(10).things

          items.first.title.should =~ /Nevermind/
        end
      end
    end
  end
end
