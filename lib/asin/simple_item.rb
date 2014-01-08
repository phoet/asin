require 'hashie'

module ASIN

  # =SimpleItem
  #
  # The +SimpleItem+ class is a wrapper for the Amazon XML-REST-Response.
  #
  # A Hashie::Mash is used for the internal data representation and can be accessed over the +raw+ attribute.
  #
  class SimpleItem

    attr_reader :raw

    def initialize(hash)
      @raw = Hashie::Mash.new(hash)
    end

    def asin
      @raw.ASIN
    end

    def title
      @raw.ItemAttributes!.Title
    end

    def amount
      @raw.ItemAttributes!.ListPrice!.Amount.to_i
    end

    def details_url
      @raw.DetailPageURL
    end

    def sales_rank
      @raw.SalesRank
    end

    def review
       @raw.EditorialReviews!.EditorialReview!.Content
    end

    def image_url
      @raw.LargeImage!.URL
    end

    # <ItemAttributes>
    def author
      @raw.ItemAttributes!.Author
    end

    def binding
      @raw.ItemAttributes!.Binding
    end

    def brand
      @raw.ItemAttributes!.Brand
    end

    def ean
      @raw.ItemAttributes!.EAN
    end
    
    def edition
      @raw.ItemAttributes!.Edition
    end
    
    def isbn
      @raw.ItemAttributes!.isbn
    end
    
    def item_dimensions
      @raw.ItemAttributes!.ItemDimensions
    end

    # hundredths of an inch
    def item_height
      @raw.ItemAttributes!.ItemDimensions.Height
    end
    
    # hundredths of an inch
    def item_length
      @raw.ItemAttributes!.ItemDimensions.Length
    end
    
    # hundredths of an inch
    def item_width
      @raw.ItemAttributes!.ItemDimensions.Width
    end
    
    # hundredths of a pound
    def item_weight
      @raw.ItemAttributes!.ItemDimensions.Weight
    end

    def package_dimensions
      @raw.ItemAttributes!.PackageDimensions
    end
    
    # hundredths of an inch
    def package_height
      @raw.ItemAttributes!.PackageDimensions.Height
    end
    
    # hundredths of an inch
    def package_length
      @raw.ItemAttributes!.PackageDimensions.Length
    end
    
    # hundredths of an inch
    def package_width
      @raw.ItemAttributes!.PackageDimensions.Width
    end
    
    # hundredths of a pound
    def package_weight
      @raw.ItemAttributes!.PackageDimensions.Weight
    end

    def label
      @raw.ItemAttributes!.Label
    end

    def language
      @raw.ItemAttributes!.Languages.Language.first.Name
    end

    def formatted_price
      @raw.ItemAttributes!.ListPrice.FormattedPrice
    end

    def manufacturer
      @raw.ItemAttributes!.Manufacturer
    end

    def mpn
      @raw.ItemAttributes!.MPN
    end

    def page_count
      @raw.ItemAttributes!.NumberOfPages
    end

    def part_number
      @raw.ItemAttributes!.PartNumber
    end

    def product_group
      @raw.ItemAttributes!.ProductGroup
    end

    def publication_date
      @raw.ItemAttributes!.PublicationDate
    end

    def publisher
      @raw.ItemAttributes!.Publisher
    end

    def sku
      @raw.ItemAttributes!.SKU
    end

    def studio
      @raw.ItemAttributes!.Studio
    end

    def total_new
      @raw.OfferSummary!.TotalNew
    end

    def total_used
      @raw.OfferSummary!.TotalUsed
    end
  end
end
