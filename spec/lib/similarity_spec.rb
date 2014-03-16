require 'spec_helper'

module ASIN
  describe ASIN do
    context "similarity" do
      before do
        options = {:secret => @secret, :key => @key, :associate_tag => @tag}
        @helper.configure options
      end

      it "should find similar items", :vcr do
        items = @helper.similar(ANY_ASIN)
        expect(items).to have(10).elements
        expect(items.first.title).to match(/Programming in Objective-C/)
      end

      it "should find similar items for multiple asins and different config", :vcr do
        items = @helper.similar(ANY_ASIN, ANY_OTHER_ASIN, :SimilarityType => :Intersection, :ResponseGroup => :Small)
        expect(items).to have(4).elements
        expect(items.first.title).to match(/Beginning iOS 5 Development/)
      end
    end
  end
end
