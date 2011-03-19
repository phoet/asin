require 'hashie'

module ASIN

  # =Item
  # 
  # The +Item+ class is a wrapper for the Amazon XML-REST-Response.
  # 
  # A Hashie::Mash is used for the internal data representation and can be accessed over the +raw+ attribute.
  # 
  class Cart

    attr_reader :raw

    def initialize(hash)
      @raw = Hashie::Mash.new(hash)
    end
    
    def cart_id
      @raw.CartId
    end

    def valid?
      @raw.Request.IsValid == 'True'
    end
  end
  
end

# {"Request"=>
#   {"IsValid"=>"",
#    "CartCreateRequest"=>
#     {"Items"=>{"Item"=>{"ASIN"=>"1430218150", "Quantity"=>"1"}}}},
#  "CartId"=>"186-7155396-8661342",
#  "HMAC"=>"kajZJ8BoZStXyHg4LfNEzyjvQJw=",
#  "URLEncodedHMAC"=>"kajZJ8BoZStXyHg4LfNEzyjvQJw%3D",
#  "PurchaseURL"=>
#   "https://www.amazon.com/gp/cart/aws-merge.html?cart-id=186-7155396-8661342%26associate-id=ws%26hmac=kajZJ8BoZStXyHg4LfNEzyjvQJw=%26SubscriptionId=AKIAJFA5X7RTOKFNPVZQ%26MergeCart=False",
#  "SubTotal"=>
#   {"Amount"=>"2639", "CurrencyCode"=>"USD", "FormattedPrice"=>"$26.39"},
#  "CartItems"=>
#   {"SubTotal"=>
#     {"Amount"=>"2639", "CurrencyCode"=>"USD", "FormattedPrice"=>"$26.39"},
#    "CartItem"=>
#     {"CartItemId"=>"U3G241HVLLB8N6",
#      "ASIN"=>"1430218150",
#      "MerchantId"=>"ATVPDKIKX0DER",
#      "SellerId"=>"A2R2RITDJNW1Q6",
#      "SellerNickname"=>"Amazon.com",
#      "Quantity"=>"1",
#      "Title"=>"Learn Objective-C on the Mac (Learn Series)",
#      "ProductGroup"=>"Book",
#      "Price"=>
#       {"Amount"=>"2639", "CurrencyCode"=>"USD", "FormattedPrice"=>"$26.39"},
#      "ItemTotal"=>
#       {"Amount"=>"2639", "CurrencyCode"=>"USD", "FormattedPrice"=>"$26.39"}}}}