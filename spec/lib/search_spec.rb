require 'spec_helper'

module ASIN
  describe ASIN do
    context "lookup and search" do
      it "should lookup a book", :vcr do
        items = @helper.lookup(ANY_ASIN)
        expect(items.first.title).to match(/Learn Objective/)
      end

      it "should have metadata", :vcr do
        items = @helper.lookup(ANY_ASIN, :ResponseGroup => :Medium)
        item = items.first
        expect(item.asin).to eql(ANY_ASIN)
        expect(item.title).to match(/Learn Objective-C/)
        expect(item.sales_rank).to eql('638093')
        expect(item.details_url).to eql("https://www.amazon.de/Learn-Objective-C-Mac-OS-iOS-ebook/dp/B008GTZ3KY?SubscriptionId=AKIAIZFAWKXP4XEATBWQ&tag=nofail-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B008GTZ3KY")
        expect(item.image_url).to eql("https://images-eu.ssl-images-amazon.com/images/I/41JtF2e17LL.jpg")
        expect(item.review).to match(/Learn to write apps for some of today's hottest technologies/)
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

      it "should search_keywords a book with fulltext", :vcr do
        items = @helper.search_keywords 'Learn', 'Objective-C'
        expect(items).to have(10).things
        expect(items.first.title).to match(/Learn Objective-C /)
      end

      it "should search_keywords never mind music", :vcr do
        items = @helper.search_keywords 'nirvana', 'never mind', :SearchIndex => :Music
        expect(items).to have(1).things
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
