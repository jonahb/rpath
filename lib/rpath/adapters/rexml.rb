require 'rexml/document'

module RPath
  module Adapters

    class REXML < RPath::Adapter

      # Returns +true+ iff +graph+ is an +REXML::Element+.
      # @param [Object] graph
      # @return [Boolean]
      def adapts?(graph)
        graph.is_a? ::REXML::Element
      end

      # Returns the name of the given element
      # @param [REXML::Element] vertex
      # @return [String]
      def name(vertex)
        vertex.name
      end

      # Returns the child elements of the given element
      # @param [REXML::Element] vertex
      # @return [Array<REXML::Element>]
      def adjacent(vertex)
        vertex.elements.to_a
      end

      # Returns the value of the named attribute on the given element.
      # @param [REXML::Element] vertex
      # @param [String, Symbol] name
      # @return [String, nil]
      def attribute(vertex, name)
        vertex.attributes[name.to_s]
      end

      # Returns the text content of the given element.
      # @param [REXML::Element] vertex
      # @return [String, nil]
      def content(vertex)
        vertex.text
      end
    end

  end
end

class REXML::Element
  # Evaluates an expression on the element
  # @example
  #   RPath.use :rexml
  #   xml = REXML::Document.new('<foo bar="baz"/>')
  #   xml.rpath { foo['bar'] } # => "baz"
  # @see #RPath
  # @return [Object]
  #
  def rpath(&block)
    RPath self, :rexml, &block
  end
end
