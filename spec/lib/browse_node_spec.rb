require 'spec_helper'

module ASIN
  describe ASIN do
    context "browse_node" do
      before do
        options = {:secret => @secret, :key => @key, :associate_tag => @tag}
        @helper.configure options
      end

      it "should lookup a browse_node", :vcr do
        item = @helper.browse_node(ANY_BROWSE_NODE_ID).first
        item.browse_node_id.should eql(ANY_BROWSE_NODE_ID)
        item.name.should eql('Comedy')
      end
    end
  end
end
