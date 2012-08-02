require 'spec_helper'

module ASIN
  describe ASIN do
    context "similarity" do
      before do
        @helper.configure :secret => @secret, :key => @key
      end

      it "should find similar items", :vcr do
        items = @helper.similar(ANY_ASIN)
        items.should have(10).elements
        items.first.title.should =~ /Learn C on the Mac/
      end

      it "should find similar items for multiple asins and different config", :vcr do
        items = @helper.similar(ANY_ASIN, ANY_OTHER_ASIN, :SimilarityType => :Intersection, :ResponseGroup => :Small)
        items.should have(2).elements
        items.first.title.should =~ /Beginning iPhone 4 Development/
      end
    end
  end
end
