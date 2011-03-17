describe ASIN do
  before do
    @helper = ASIN.client
    @helper.configure :logger => nil

    @secret = ENV['ASIN_SECRET']
    @key = ENV['ASIN_KEY']
    puts "configure #{@secret} and #{@key} for this test"
  end

  context "configuration" do
    it "should fail without secret and key" do
      lambda { @helper.lookup 'bla' }.should raise_error(RuntimeError)
    end

    it "should fail with wrong configuration key" do
      lambda { @helper.configure :wrong => 'key' }.should raise_error(NoMethodError)
    end

    it "should not override the configuration" do
      config = @helper.configure :key => 'wont get overridden'
      config.key.should_not be_nil

      config = @helper.configure :secret => 'is also set'
      config.key.should_not be_nil
      config.secret.should_not be_nil
    end

    it "should work with a configuration block" do
      config = ASIN::Configuration.configure do |config|
        config.key = 'bla'
      end
      config.key.should eql('bla')
    end
  end

  context "lookup and search" do
    before do
      @helper.configure :secret => @secret, :key => @key
    end

    it "should lookup a book" do
      item = @helper.lookup('1430218150')
      item.title.should =~ /Learn Objective/
    end

    it "should search_keywords a book with fulltext" do
      items = @helper.search_keywords 'Learn', 'Objective-C'
      items.should have(10).things

      items.first.title.should =~ /Learn Objective/
    end

    it "should search_keywords never mind music" do
      items = @helper.search_keywords 'nirvana', 'never mind', :SearchIndex => :Music
      items.should have(10).things

      items.first.title.should =~ /Nevermind/
    end

    it "should search music" do
      items = @helper.search :SearchIndex => :Music
      items.should have(0).things
    end

    it "should search never mind music" do
      items = @helper.search :Keywords => 'nirvana', :SearchIndex => :Music
      items.should have(10).things

      items.first.title.should =~ /Nevermind/
    end
  end
  
  context "cart helpers" do
    before do
      @helper.configure :secret => @secret, :key => @key
      @items = [
                {:quantity=>3, :offer_listing_id=>"321"},
                {:quantity=>2, :asin=>"foo"},
                {:quantity=>4, :cart_item_id=>"bar"}]
    end
    
    describe "#create_cart_item_params" do
      it "should filter items with a valid Item Identifier" do
        items = @items + [{:foo => "bar"}]
        @helper.create_cart_item_params(:items => items).size.should == @items.size * 2
      end
      
      it "should use the default quantity of 1" do
        items = [{:asin => "foo"}]
        params = @helper.create_cart_item_params(:items => items)
        params["Item.1.Quantity"].should == 1
      end

      it "should reject items without a valid item identifier" do
        items = [{:foo => "bar"}]
        params = @helper.create_cart_item_params(:items => items)
        params.should be_empty
      end
      
      it "should return a valid hash of parameters" do
        params = @helper.create_cart_item_params(:items => @items)
        params.keys.should be_any {|m| m =~ /Item\.\d\.ASIN/ }
        params.keys.should be_any {|m| m =~ /Item\.\d\.OfferListingId/ }
        params.keys.should be_any {|m| m =~ /Item\.\d\.CartItemId/ }
        params.values.should include "321"
        params.values.should include "foo"
        params.values.should include "bar"
      end      
    end

  end

  context "cart operations" do
    describe "cart_create" do
      it "should create a new remote cart" do
        response = @helper.cart_create :items => [{:asin => '0534950973', :quantity => 1}]
        response.should have_key "CartId"
      end
    end

    describe "cart modification" do
      before do
        @asin = '0534950973'
        response = @helper.cart_create :items => [{:asin => @asin, :quantity => 1}]
        @cart_id = response["CartId"]
        @cart_item_id = response["CartItems"]["CartItem"]["CartItemId"]
        # @hmac = response["URLEncodedHMAC"]
        @hmac = response["HMAC"]
      end
      
      it "should fail with a missing HMAC" do
        lambda { @helper.create_cart_params :cart_id => @cart_id }.should raise_error(RuntimeError)
      end

      it "should fail with a missing CartId" do
        lambda { @helper.create_cart_params :hmac => @hmac }.should raise_error(RuntimeError)
      end

      describe "cart_add" do
        it "should add an item to the cart" do
          response = @helper.cart_add(:cart_id => @cart_id, :hmac => @hmac, 
                                      :items => [{:asin => '0321486811'}])
          response["CartItems"]["CartItem"].should be_any {|m| m["ASIN"] == "0321486811"}
        end
      end

      describe "cart_clear" do
        it "should remove all the items from a cart" do
          response = @helper.cart_clear(:cart_id => @cart_id, :hmac => @hmac)
          response.should_not have_key "CartItems"
        end
      end

      describe "cart_update" do
        it "should update the quantity of an item in the cart" do
          response = @helper.cart_update(:cart_id => @cart_id, :hmac => @hmac,
                                         :items => [{:cart_item_id => @cart_item_id, :quantity => 2}])
          response["CartItems"]["CartItem"]["Quantity"].to_i.should == 2
        end
      end
      
      describe "cart_remove" do
        it "should remove an item from the cart" do
          @helper.cart_add(:cart_id => @cart_id, :hmac => @hmac, 
                                      :items => [{:asin => '0321486811'},{:asin => '0321751043'}])
          response = @helper.cart_remove(:cart_id => @cart_id, :hmac => @hmac,
                                         :items => [{:cart_item_id => @cart_item_id, :quantity => 0}])
          response["CartItems"]["CartItem"].should_not be_any {|m| m["ASIN"] == @asin} 
        end
      end

    end

  end
end

