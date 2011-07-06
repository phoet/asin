require 'hashie'

module ASIN

  # =SimpleNode
  #
  # The +SimpleNode+ class is a wrapper for the Amazon XML-REST-Response.
  #
  # A Hashie::Mash is used for the internal data representation and can be accessed over the +raw+ attribute.
  #
  class SimpleNode

    attr_reader :raw

    def initialize(hash)
      @raw = Hashie::Mash.new(hash)
    end

    def name
      @raw.Name
    end

    def node_id
      @raw.BrowseNodeId
    end

    def children
      return [] unless @raw.Children
      @raw.Children.BrowseNode.is_a?(Array) ? @raw.Children.BrowseNode : [@raw.Children.BrowseNode]
    end

    def ancestors
      return [] unless @raw.Ancestors
      @raw.Ancestors.BrowseNode.is_a?(Array) ? @raw.Ancestors.BrowseNode : [@raw.Ancestors.BrowseNode]
    end

    def top_item_set
      return [] unless @raw.TopItemSet
      @raw.TopItemSet.TopItem.is_a?(Array) ? @raw.TopItemSet.TopItem : [@raw.TopItemSet.TopItem]
    end

  end

end
