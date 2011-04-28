require 'hashie'


module ASIN

  # =Item
  #
  # The +Item+ class is a wrapper for the Amazon XML-REST-Response.
  #
  # A Hashie::Mash is used for the internal data representation and can be accessed over the +raw+ attribute.
  #
  class Item

    attr_reader :raw

    def initialize(hash)
      @raw = Hashie::Mash.new(hash)
    end

    def asin
      @raw.ASIN
    end
    alias :id :asin
    alias :to_param :asin

    def title
      @raw.ItemAttributes!.Title
    end

    def cents
      price_container = @raw.ItemAttributes!.ListPrice || @raw.OfferSummary!.LowestUsedPrice
      if price_container and amount = price_container.Amount
        amount.to_i
      end
    end

    def url
      @raw.DetailPageURL
    end

    def description
      desc = ''
      review = @raw.EditorialReviews!.EditorialReview!
      if review
        if review.respond_to?(:Content)
          desc
        else
          review.map{|item| item.Content}.join('.')
        end
      else
        desc = (features = @raw.ItemAttributes!.Feature! and features.join('.'))
      end
      desc
    end

    def image
      @raw.LargeImage!.URL
    end
  end

end
