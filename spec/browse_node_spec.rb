require 'spec_helper'

module ASIN
  describe ASIN do
    before do
      ASIN::Configuration.reset
      @helper = ASIN::Client.instance
      @helper.configure :logger => nil

      @secret = ENV['ASIN_SECRET']
      @key = ENV['ASIN_KEY']
      puts "configure #{@secret} and #{@key} for this test"
    end

    context "lookup and search" do
      before do
        @helper.configure :secret => @secret, :key => @key
      end

      it "should lookup a book" do
        item = @helper.browse_node(ANY_BROWSE_NODE_ID)
        item.node_id.should eql(ANY_BROWSE_NODE_ID)
        item.name.should eql('Comedy')
      end
    end
  end
end
