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
        item.sales_rank.should == '209840'
        item.amount.should eql(3999)
        item.details_url.should eql("http://www.amazon.com/Learn-Objective-C-Mac-Series/dp/1430218150%3FSubscriptionId%3DAKIAIBNLWSCV5OXMPD6A%26tag%3Dphoet-20%26linkCode%3Dxm2%26camp%3D2025%26creative%3D165953%26creativeASIN%3D1430218150")
        item.image_url.should eql("http://ecx.images-amazon.com/images/I/41kq5bDvnUL.jpg")
        item.review.should =~ /Take your coding skills to the next level/

        # <ItemAttributes>
        item.item_height.should == "925"
        item.item_length.should == "752"
        item.item_width.should == "71"
        item.item_weight.should == "137"
        item.package_height.should == "102"
        item.package_length.should == "921"
        item.package_width.should == "701"
        item.package_weight.should == "123"

        item.author.count.should == 2
        item.author.first.should == "Scott Knaster"
        item.binding.should == "Paperback"
        item.brand.should == "Apress"
        item.ean.should == "9781430218159"
        item.edition == "1"
        item.isbn == "1430218150"
        item.label.should == "Apress"
        item.language.should == "English"
        item.formatted_price.should == "$39.99"
        item.manufacturer.should == "Apress"
        item.mpn.should == "978-1-4302-1815-9"
        item.page_count.should == "360"
        item.part_number.should == "978-1-4302-1815-9"
        item.product_group.should == "Book"
        item.publication_date.should == "2009-01-07"
        item.publisher.should == "Apress"
        item.sku.should == "mon0001920250"
        item.studio.should == "Apress"

        # <OfferSummary>
        item.total_new.should == "56"
        item.total_used.should == "62"
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
