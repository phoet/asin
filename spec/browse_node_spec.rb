require 'spec_helper'

module ASIN
  describe ASIN do
    context "browse_node" do
      before do
        @helper.configure :secret => @secret, :key => @key
      end

      it "should lookup a browse_node" do
        VCR.use_cassette("browse_node_#{ANY_BROWSE_NODE_ID}", :match_requests_on => [:host, :path]) do
          item = @helper.browse_node(ANY_BROWSE_NODE_ID)
          item.node_id.should eql(ANY_BROWSE_NODE_ID)
          item.name.should eql('Comedy')
        end
      end
    end
  end
end
