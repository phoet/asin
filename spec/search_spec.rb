require 'spec_helper'

module ASIN
  describe ASIN do
    context "lookup and search" do
      before do
        options = {:secret => @secret, :key => @key, :associate_tag => @tag}
        @helper.configure options
      end

      it "should lookup a book", :vcr do
        items = @helper.lookup(ANY_ASIN)
        items.first.title.should =~ /Learn Objective/
      end

      it "should have metadata", :vcr do
        items = @helper.lookup(ANY_ASIN, :ResponseGroup => :Medium)
        item = items.first
        item.asin.should eql(ANY_ASIN)
        item.title.should =~ /Learn Objective/
        item.amount.should eql(3999)
        item.details_url.should eql("http://www.amazon.com/Learn-Objective-C-Mac-Series/dp/1430218150%3FSubscriptionId%3DAKIAIBNLWSCV5OXMPD6A%26tag%3Dphoet-20%26linkCode%3Dxm2%26camp%3D2025%26creative%3D165953%26creativeASIN%3D1430218150")
        item.image_url.should eql("http://ecx.images-amazon.com/images/I/41kq5bDvnUL.jpg")
        item.review.should =~ /Take your coding skills to the next level/
      end

      it "should lookup multiple response groups", :vcr do
        items = @helper.lookup(ANY_ASIN, :ResponseGroup => [:Small, :AlternateVersions])

        item = items.first
        item.asin.should eql(ANY_ASIN)
        item.title.should =~ /Learn Objective/
      end

      it "should lookup multiple books", :vcr do
        items = @helper.lookup(ANY_ASIN, ANY_OTHER_ASIN)

        items.last.title.should =~ /Beginning iPhone Development/
        items.first.title.should =~ /Learn Objective-C/
      end

      it "should return a custom item class", :vcr do
        module TEST
          class TestItem
            attr_accessor :testo
            def initialize(hash)
              @testo = hash
            end
          end
        end
        @helper.configure :item_type => TEST::TestItem
        @helper.lookup(ANY_ASIN).first.testo.should_not be_nil
      end

      it "should return a raw value", :vcr do
        @helper.configure :item_type => :raw
        @helper.lookup(ANY_ASIN).first['ItemAttributes']['Title'].should_not be_nil
      end

      it "should return a mash value", :vcr do
        @helper.configure :item_type => :mash
        @helper.lookup(ANY_ASIN).first.ItemAttributes.Title.should_not be_nil
      end

      it "should return a rash value", :vcr do
        @helper.configure :item_type => :rash
        @helper.lookup(ANY_ASIN).first.item_attributes.title.should_not be_nil
      end

      it "should search_keywords and handle a single result", :vcr do
        items = @helper.search_keywords('0471317519')
        items.first.title.should =~ /A Self-Teaching Guide/
      end

      it "should search_keywords a book with fulltext", :vcr do
        items = @helper.search_keywords 'Learn', 'Objective-C'
        items.should have(10).things
        items.first.title.should =~ /Learn Objective-C /
      end

      it "should search_keywords never mind music", :vcr do
        items = @helper.search_keywords 'nirvana', 'never mind', :SearchIndex => :Music
        items.should have(10).things
        items.map(&:title).join.should =~ /Nevermind/
      end

      it "should search music", :vcr do
        items = @helper.search :SearchIndex => :Music
        items.should have(0).things
      end

      it "should search never mind music", :vcr do
        items = @helper.search :Keywords => 'nirvana', :SearchIndex => :Music
        items.should have(10).things
        items.map(&:title).join.should =~ /Nevermind/
      end
    end
  end
end
