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
        expect(items.first.title).to match(/Learn Objective/)
      end

      it "should have metadata", :vcr do
        items = @helper.lookup(ANY_ASIN, :ResponseGroup => :Medium)
        item = items.first
        expect(item.asin).to eql(ANY_ASIN)
        expect(item.title).to match(/Learn Objective/)
        expect(item.sales_rank).to eql('209840')
        expect(item.amount).to eql(3999)
        expect(item.details_url).to eql("http://www.amazon.com/Learn-Objective-C-Mac-Series/dp/1430218150%3FSubscriptionId%3DAKIAIBNLWSCV5OXMPD6A%26tag%3Dphoet-20%26linkCode%3Dxm2%26camp%3D2025%26creative%3D165953%26creativeASIN%3D1430218150")
        expect(item.image_url).to eql("http://ecx.images-amazon.com/images/I/41kq5bDvnUL.jpg")
        expect(item.review).to match(/Take your coding skills to the next level/)

        # <ItemAttributes>
        expect(item.item_height).to       eql("925")
        expect(item.item_length).to       eql("752")
        expect(item.item_width).to        eql("71")
        expect(item.item_weight).to       eql("137")
        expect(item.package_height).to    eql("102")
        expect(item.package_length).to    eql("921")
        expect(item.package_width).to     eql("701")
        expect(item.package_weight).to    eql("123")
        expect(item.author.count).to      eql(2)
        expect(item.author.first).to      eql("Scott Knaster")
        expect(item.binding).to           eql("Paperback")
        expect(item.brand).to             eql("Apress")
        expect(item.ean).to               eql("9781430218159")
        expect(item.edition).to           eql("1")
        expect(item.isbn).to              eql("1430218150")
        expect(item.label).to             eql("Apress")
        expect(item.language).to          eql("English")
        expect(item.formatted_price).to   eql("$39.99")
        expect(item.manufacturer).to      eql("Apress")
        expect(item.mpn).to               eql("978-1-4302-1815-9")
        expect(item.page_count).to        eql("360")
        expect(item.part_number).to       eql("978-1-4302-1815-9")
        expect(item.product_group).to     eql("Book")
        expect(item.publication_date).to  eql("2009-01-07")
        expect(item.publisher).to         eql("Apress")
        expect(item.sku).to               eql("mon0001920250")
        expect(item.studio).to            eql("Apress")

        # <OfferSummary>
        expect(item.total_new).to eql("56")
        expect(item.total_used).to eql("62")
      end

      it "should lookup multiple response groups", :vcr do
        items = @helper.lookup(ANY_ASIN, :ResponseGroup => [:Small, :AlternateVersions])

        item = items.first
        expect(item.asin).to eql(ANY_ASIN)
        expect(item.title).to match(/Learn Objective/)
      end

      it "should lookup multiple books", :vcr do
        items = @helper.lookup(ANY_ASIN, ANY_OTHER_ASIN)

        expect(items.last.title).to match(/Beginning iPhone Development/)
        expect(items.first.title).to match(/Learn Objective-C/)
      end

      it "should search_keywords and handle a single result", :vcr do
        items = @helper.search_keywords('0471317519')
        expect(items.first.title).to match(/A Self-Teaching Guide/)
      end

      it "should search_keywords a book with fulltext", :vcr do
        items = @helper.search_keywords 'Learn', 'Objective-C'
        expect(items).to have(10).things
        expect(items.first.title).to match(/Learn Objective-C /)
      end

      it "should search_keywords never mind music", :vcr do
        items = @helper.search_keywords 'nirvana', 'never mind', :SearchIndex => :Music
        expect(items).to have(10).things
        expect(items.map(&:title).join).to match(/Nevermind/)
      end

      it "should search music", :vcr do
        items = @helper.search :SearchIndex => :Music
        expect(items).to have(0).things
      end

      it "should search never mind music", :vcr do
        items = @helper.search :Keywords => 'nirvana', :SearchIndex => :Music
        expect(items).to have(10).things
        expect(items.map(&:title).join).to match(/Nevermind/)
      end
    end
  end
end
