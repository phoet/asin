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
        items.should have(10).elements
        items.first.title.should =~ /Programming in Objective-C/
      end

      it "should find similar items for multiple asins and different config", :vcr do
        items = @helper.similar(ANY_ASIN, ANY_OTHER_ASIN, :SimilarityType => :Intersection, :ResponseGroup => :Small)
        items.should have(5).elements
        items.first.title.should =~ /Beginning iOS 5 Development/
      end
    end
  end
end
