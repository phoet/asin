require 'spec_helper'

module ASIN
  describe ASIN do
    before do
      options = {:secret => @secret, :key => @key, :associate_tag => @tag}
      @helper.configure options
    end

    context "cart" do

      it "should create a cart", :vcr do
        cart = @helper.create_cart({:asin => ANY_ASIN, :quantity => 1}, {:asin => ANY_OTHER_ASIN, :quantity => 2})
        cart.valid?.should be(true)
        cart.empty?.should be(false)
      end

      it "should handle item paramters" do
        params = @helper.send(:create_item_params, [{:asin => 'any_asin', :quantity => 1}, {:cart_item_id => 'any_cart_item_id', :quantity => 2}, {:offer_listing_id => 'any_offer_listing_id', :quantity => 3},{:cart_item_id => 'any_cart_item_id', :action => :SaveForLater}])
        params.should eql({"Item.0.ASIN"=>"any_asin", "Item.0.Quantity"=>"1", "Item.1.CartItemId"=>"any_cart_item_id", "Item.1.Quantity"=>"2", "Item.2.OfferListingId"=>"any_offer_listing_id", "Item.2.Quantity"=>"3", "Item.3.CartItemId"=>"any_cart_item_id", "Item.3.Action"=>"SaveForLater"})
      end

      context "with an existing cart" do

        it "should clear a cart", :vcr do
          @cart = @helper.create_cart({:asin => ANY_ASIN, :quantity => 1})
          cart = @helper.clear_cart(@cart)
          cart.valid?.should be(true)
          cart.empty?.should be(true)
        end

        it "should get a cart", :vcr do
          @cart = @helper.create_cart({:asin => ANY_ASIN, :quantity => 1})
          cart = @helper.get_cart(@cart.cart_id, @cart.hmac)
          cart.valid?.should be(true)
          cart.empty?.should be(false)
        end

        it "should add items to a cart", :vcr do
          @cart = @helper.create_cart({:asin => ANY_ASIN, :quantity => 1})
          cart = @helper.add_items(@cart, {:asin => ANY_OTHER_ASIN, :quantity => 2})
          cart.valid?.should be(true)
          cart.empty?.should be(false)
          cart.items.should have(2).things
        end

        it "should update a cart", :vcr do
          @cart = @helper.create_cart({:asin => ANY_ASIN, :quantity => 1})
          item_id = @cart.items.first.cart_item_id
          cart = @helper.update_items(@cart, {:cart_item_id => item_id, :action => 'SaveForLater'}, {:cart_item_id => item_id, :quantity => 7})
          cart.saved_items.should have(1).things
          cart.valid?.should be(true)
        end

      end
    end
  end
end
