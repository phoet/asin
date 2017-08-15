require 'spec_helper'

module ASIN
  describe ASIN do
    context "browse_node" do
      it "should lookup a browse_node", :vcr do
        item = @helper.browse_node(ANY_BROWSE_NODE_ID).first
        expect(item.browse_node_id).to eql(ANY_BROWSE_NODE_ID)
        expect(item.name).to eql('Kategorien')
      end
    end
  end
end
