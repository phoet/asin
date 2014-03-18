module ASIN
  module Adapter
    def handle_type(data, type)
      Hashie::Rash.new(data).tap do |rash|
        rash.instance_eval do
          case type
          when :cart
            def url
              purchase_url
            end

            def price
              sub_total.formatted_price
            end

            def items
              return [] unless cart_items
              cart_items.cart_item.is_a?(Array) ? cart_items.cart_item : [cart_items.cart_item]
            end

            def saved_items
              return [] unless saved_for_later_items
              saved_for_later_items.saved_for_later_item.is_a?(Array) ? saved_for_later_items.saved_for_later_item : [saved_for_later_items.saved_for_later_item]
            end

            def valid?
              request.is_valid == 'True'
            end

            def empty?
              cart_items.nil?
            end

          when :item
            def title
              item_attributes!.title
            end

            def amount
              item_attributes!.list_price!.amount.to_i
            end

            def details_url
              detail_page_url
            end

            def review
              editorial_reviews!.editorial_review!.content
            end

            def image_url
              large_image!.url
            end

            def review
              EditorialReviews!.EditorialReview!.Content
            end

            def image_url
              LargeImage!.URL
            end

            # <ItemAttributes>
            def author
              item_attributes!.author
            end

            def binding
              item_attributes!.binding
            end

            def brand
              item_attributes!.brand
            end

            def ean
              item_attributes!.ean
            end

            def edition
              item_attributes!.edition
            end

            def isbn
              item_attributes!.isbn
            end

            def item_dimensions
              item_attributes!.item_dimensions
            end

            # hundredths of an inch
            def item_height
              item_attributes!.item_dimensions.height
            end

            # hundredths of an inch
            def item_length
              item_attributes!.item_dimensions[:length]
            end

            # hundredths of an inch
            def item_width
              item_attributes!.item_dimensions.width
            end

            # hundredths of a pound
            def item_weight
              item_attributes!.item_dimensions.weight
            end

            def package_dimensions
              item_attributes!.package_dimensions
            end

            # hundredths of an inch
            def package_height
              item_attributes!.package_dimensions.height
            end

            # hundredths of an inch
            def package_length
              item_attributes!.package_dimensions[:length]
            end

            # hundredths of an inch
            def package_width
              item_attributes!.package_dimensions.width
            end

            # hundredths of a pound
            def package_weight
              item_attributes!.package_dimensions.weight
            end

            def label
              item_attributes!.label
            end

            def language
              item_attributes!.languages.language.first.name
            end

            def formatted_price
              item_attributes!.list_price.formatted_price
            end

            def manufacturer
              item_attributes!.manufacturer
            end

            def mpn
              item_attributes!.mpn
            end

            def page_count
              item_attributes!.number_of_pages
            end

            def part_number
              item_attributes!.part_number
            end

            def product_group
              item_attributes!.product_group
            end

            def publication_date
              item_attributes!.publication_date
            end

            def publisher
              item_attributes!.publisher
            end

            def sku
              item_attributes!.sku
            end

            def studio
              item_attributes!.studio
            end

            def total_new
              offer_summary!.total_new
            end

            def total_used
              offer_summary!.total_used
            end

          when :node
            def node_id
              browse_node_id
            end

            def children
              return [] unless children
              children.browse_node.is_a?(Array) ? children.browse_node : [children.browse_node]
            end

            def ancestors
              return [] unless ancestors
              ancestors.browse_node.is_a?(Array) ? ancestors.browse_node : [ancestors.browse_node]
            end

            def top_item_set
              return [] unless top_item_set
              top_item_set.top_item.is_a?(Array) ? top_item_set.top_item : [top_item_set.top_item]
            end
          end
        end
      end
    end
  end

  module Client
    # REM (ps) this is a workaround for jruby, because they don't support Module.prepend https://github.com/jruby/jruby/issues/751
    remove_method :handle_type
    include ASIN::Adapter
  end
end
