require 'nokogiri'

module RPath
  module Adapters

    class Nokogiri < RPath::Adapter

      # Returns +true+ iff +graph+ is a +Nokogiri::XML::Node+.
      # @param [Object] graph
      # @return [Boolean]
      def adapts?(graph)
        graph.is_a? ::Nokogiri::XML::Node
      end

      # Returns the name of the given node
      # @param [Nokogiri::XML::Node] vertex
      # @return [String]
      def name(vertex)
        vertex.name
      end

      # Returns the child elements of the given node
      # @param [Nokogiri::XML::Node] vertex
      # @return [Array<Nokogiri::XML::Node>]
      def adjacent(vertex)
        vertex.children.to_a
      end

      # Returns the value of the named attribute on the given node.
      # @param [Nokogiri::XML::Node] vertex
      # @param [String, Symbol] name
      # @return [String, nil]
      def attribute(vertex, name)
        vertex[name.to_s]
      end

      # Returns the text content of the given node.
      # @param [Nokogiri::XML::Node] vertex
      # @return [String, nil]
      def content(vertex)
        vertex.text
      end
    end

  end
end

class Nokogiri::XML::Node
  # Evaluates an expression on the element
  # @example
  #   RPath.use :nokogiri
  #   xml = Nokogiri::XML('<foo bar="baz"/>')
  #   xml.rpath { foo['bar'] } # => "baz"
  # @see #RPath
  # @return [Object]
  #
  def rpath(&block)
    RPath self, :nokogiri, &block
  end
end
