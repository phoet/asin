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
        cart.request.is_valid.should eql('True')
        cart.cart_items.should be_nil
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
          item_id = @cart.items.first.CartItemId
          cart = @helper.update_items(@cart, {:cart_item_id => item_id, :action => 'SaveForLater'}, {:cart_item_id => item_id, :quantity => 7})
          cart.saved_items.should have(1).things
          cart.valid?.should be(true)
        end

      end

      context SimpleCart do

        before do
          @helper.configure :secret => @secret, :key => @key
          @two_items = {"Request"=>
                        {"IsValid"=>"True",
                         "CartAddRequest"=>
                         {"CartId"=>"186-8702292-9782208",
                          "HMAC"=>"Ck5MXUE+OQiC/Jh8u6NhBf5FbV8=",
                          "Items"=>{"Item"=>{"ASIN"=>"1430216263", "Quantity"=>"2"}}}},
                        "CartId"=>"186-8702292-9782208",
                        "HMAC"=>"Ck5MXUE+OQiC/Jh8u6NhBf5FbV8=",
                        "URLEncodedHMAC"=>"Ck5MXUE%2BOQiC%2FJh8u6NhBf5FbV8%3D",
                        "PurchaseURL"=>
                        "https://www.amazon.com/gp/cart/aws-merge.html?cart-id=186-8702292-9782208%26associate-id=ws%26hmac=Ck5MXUE%2BOQiC/Jh8u6NhBf5FbV8=%26SubscriptionId=AKIAJFA5X7RTOKFNPVZQ%26MergeCart=False",
                        "SubTotal"=>
                        {"Amount"=>"6595", "CurrencyCode"=>"USD", "FormattedPrice"=>"$65.95"},
                        "CartItems"=>
                        {"SubTotal"=>
                         {"Amount"=>"6595", "CurrencyCode"=>"USD", "FormattedPrice"=>"$65.95"},
                         "CartItem"=>
                         [{"CartItemId"=>"U3CFEHHIPJNW3L",
                           "ASIN"=>"1430216263",
                           "MerchantId"=>"ATVPDKIKX0DER",
                           "SellerId"=>"A2R2RITDJNW1Q6",
                           "SellerNickname"=>"Amazon.com",
                           "Quantity"=>"2",
                           "Title"=>"Beginning iPhone Development: Exploring the iPhone SDK",
                           "ProductGroup"=>"Book",
                           "Price"=>
                           {"Amount"=>"1978", "CurrencyCode"=>"USD", "FormattedPrice"=>"$19.78"},
                           "ItemTotal"=>
                           {"Amount"=>"3956", "CurrencyCode"=>"USD", "FormattedPrice"=>"$39.56"}},
                          {"CartItemId"=>"U3G241HVLLB8N6",
                           "ASIN"=>"1430218150",
                           "MerchantId"=>"ATVPDKIKX0DER",
                           "SellerId"=>"A2R2RITDJNW1Q6",
                           "SellerNickname"=>"Amazon.com",
                           "Quantity"=>"1",
                           "Title"=>"Learn Objective-C on the Mac (Learn Series)",
                           "ProductGroup"=>"Book",
                           "Price"=>
                           {"Amount"=>"2639", "CurrencyCode"=>"USD", "FormattedPrice"=>"$26.39"},
                           "ItemTotal"=>
                           {"Amount"=>"2639",
                            "CurrencyCode"=>"USD",
                            "FormattedPrice"=>"$26.39"}}]}}
          @one_item = {"Request"=>
                       {"IsValid"=>"True",
                        "CartCreateRequest"=>
                        {"Items"=>{"Item"=>{"ASIN"=>"1430218150", "Quantity"=>"1"}}}},
                       "CartId"=>"176-9182855-2326919",
                       "HMAC"=>"KgeVCA0YJTbuN/7Ibakrk/KnHWA=",
                       "URLEncodedHMAC"=>"KgeVCA0YJTbuN%2F7Ibakrk%2FKnHWA%3D",
                       "PurchaseURL"=>
                       "https://www.amazon.com/gp/cart/aws-merge.html?cart-id=176-9182855-2326919%26associate-id=ws%26hmac=KgeVCA0YJTbuN/7Ibakrk/KnHWA=%26SubscriptionId=AKIAJFA5X7RTOKFNPVZQ%26MergeCart=False",
                       "SubTotal"=>
                       {"Amount"=>"2639", "CurrencyCode"=>"USD", "FormattedPrice"=>"$26.39"},
                       "CartItems"=>
                       {"SubTotal"=>
                        {"Amount"=>"2639", "CurrencyCode"=>"USD", "FormattedPrice"=>"$26.39"},
                        "CartItem"=>
                        {"CartItemId"=>"U3G241HVLLB8N6",
                         "ASIN"=>"1430218150",
                         "MerchantId"=>"ATVPDKIKX0DER",
                         "SellerId"=>"A2R2RITDJNW1Q6",
                         "SellerNickname"=>"Amazon.com",
                         "Quantity"=>"1",
                         "Title"=>"Learn Objective-C on the Mac (Learn Series)",
                         "ProductGroup"=>"Book",
                         "Price"=>
                         {"Amount"=>"2639", "CurrencyCode"=>"USD", "FormattedPrice"=>"$26.39"},
                         "ItemTotal"=>
                         {"Amount"=>"2639", "CurrencyCode"=>"USD", "FormattedPrice"=>"$26.39"}}}}
        end

        it "should handle response data" do
          cart = SimpleCart.new(@two_items)
          cart.valid?.should be(true)
          cart.cart_id.should eql('186-8702292-9782208')
          cart.hmac.should eql('Ck5MXUE+OQiC/Jh8u6NhBf5FbV8=')
          cart.url.should eql('https://www.amazon.com/gp/cart/aws-merge.html?cart-id=186-8702292-9782208%26associate-id=ws%26hmac=Ck5MXUE%2BOQiC/Jh8u6NhBf5FbV8=%26SubscriptionId=AKIAJFA5X7RTOKFNPVZQ%26MergeCart=False')
          cart.price.should eql('$65.95')
          cart.items.first.CartItemId eql('U3G241HVLLB8N6')
        end

        it "should handle one item" do
          cart = SimpleCart.new(@two_items)
          cart.items.first.CartItemId eql('U3G241HVLLB8N6')
        end

      end
    end
  end
end
