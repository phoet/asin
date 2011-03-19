require 'spec_helper'

module ASIN
  describe ASIN do

    before do
      @helper = ASIN.client
      @helper.configure :logger => nil

      @secret = ENV['ASIN_SECRET']
      @key = ENV['ASIN_KEY']
      puts "configure #{@secret} and #{@key} for this test"
    end

    context "cart" do
      before do
        @helper.configure :secret => @secret, :key => @key
        @ok = {"Request"=>
               {"IsValid"=>"True",
                "CartCreateRequest"=>
                {"Items"=>{"Item"=>{"ASIN"=>"1430218150", "Quantity"=>"1"}}}},
               "CartId"=>"186-7155396-8661342",
               "HMAC"=>"kajZJ8BoZStXyHg4LfNEzyjvQJw=",
               "URLEncodedHMAC"=>"kajZJ8BoZStXyHg4LfNEzyjvQJw%3D",
               "PurchaseURL"=>
               "https://www.amazon.com/gp/cart/aws-merge.html?cart-id=186-7155396-8661342%26associate-id=ws%26hmac=kajZJ8BoZStXyHg4LfNEzyjvQJw=%26SubscriptionId=AKIAJFA5X7RTOKFNPVZQ%26MergeCart=False",
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
        cart = Cart.new(@ok)
        cart.valid?.should be(true)
        cart.cart_id.should eql('186-7155396-8661342')
      end

      it "should create a cart" do
        cart = @helper.cart :create, [{:asin => ANY_ASIN, :quantity => 1}]
        cart.valid?.should be(true)
      end
    end
  end
end
