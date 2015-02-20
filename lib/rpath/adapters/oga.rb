require 'oga'

module RPath
  module Adapters

    class Oga < RPath::Adapter

      # Returns +true+ iff +graph+ is an Oga::XML::Document or an Oga::XML::Element
      # @param [Object] graph
      # @return [Boolean]
      def adapts?(graph)
        graph.is_a?(::Oga::XML::Element) || graph.is_a?(::Oga::XML::Document)
      end

      # Returns the name of the given node
      # @param [Oga::XML::Document, Oga::XML::Element] vertex
      # @return [String]
      def name(vertex)
        vertex.is_a?(::Oga::XML::Element) ? vertex.name : nil
      end

      # Returns the child elements of the given node
      # @param [Oga::XML::Document, Oga::XML::Element] vertex
      # @return [Array<Oga::XML::Element>]
      def adjacent(vertex)
        vertex.children.select { |child| child.is_a?(::Oga::XML::Element) }
      end

      # Returns the value of the named attribute on the given node.
      # @param [Oga::XML::Document, Oga::XML::Element] vertex
      # @param [String, Symbol] name
      # @return [String, nil]
      def attribute(vertex, name)
        vertex.is_a?(::Oga::XML::Element) ? vertex.get(name) : nil
      end

      # Returns the text content of the given node.
      # @param [Oga::XML::Document, Oga::XML::Element] vertex
      # @return [String, nil]
      def content(vertex)
        vertex.is_a?(::Oga::XML::Element) ? vertex.text : nil
      end
    end

  end
end

class Oga::XML::Document
  # Evaluates an RPath expression on the document
  # @example
  #   RPath.use :oga
  #   xml = Oga.parse_xml('<foo bar="baz"/>')
  #   xml.rpath { foo['bar'] } # => "baz"
  # @see #RPath
  # @return [Object]
  #
  def rpath(&block)
    RPath self, :oga, &block
  end
end

class Oga::XML::Element
  # Evaluates an RPath expression on the element
  # @example
  #   RPath.use :oga
  #   xml = Oga.parse_xml('<foo><bar baz="qux"/></foo>')
  #   xml.children.first.rpath { bar['baz'] } # => "qux"
  # @see #RPath
  # @return [Object]
  #  
  def rpath(&block)
    RPath self, :oga, &block
  end
end
