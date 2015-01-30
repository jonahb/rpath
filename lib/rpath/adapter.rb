module RPath

  # An RPath adapter makes it possible to evaluate RPath expressions on some
  # type of graph. There are built-in adapters for Nokogiri, REXML, and the
  # filesystem. To build an adapter for another graph type, inherit from
  # {Adapter} and implement the abstract methods.
  # @abstract
  #
  class Adapter
    # Used to infer the adapter when {#RPath} is called without an explicit
    # adapter. The first registered adapter whose {#adapts?} returns +true+
    # is chosen. The default implementation returns +false+.
    # @param [Object] graph
    # @return [Boolean]
    # @see #RPath
    # @see RPath.use
    def adapts?(graph)
      false
    end

    # Returns the root of the given graph, the vertex where evaluation
    # begins. The default implementation returns the given graph.
    # the given graph.
    # @param [Object] graph
    # @return [Object]
    def root(graph)
      graph
    end

    # Returns the name of the given vertex
    # @abstract
    # @param [Object] vertex
    # @return [String]
    def name(vertex)
      raise NotImplementedError
    end

    # Returns the vertices adjacent to the given vertex.
    # @abstract
    # @param [Object] vertex
    # @return [Array]
    def adjacent(vertex)
      raise NotImplementedError
    end

    # Returns the value of attribute +name+ of +vertex+ or +nil+ if no such
    # attribute exists.
    # @abstract
    # @param [Object] vertex
    # @param [String, Symbol] name
    # @return [Object, nil]
    def attribute(vertex, name)
      raise NotImplementedError
    end

    # Returns the content of +vertex+ or nil if no content exists.
    # @abstract
    # @param [Object] vertex
    # @return [Object, nil]
    def content(vertex)
      raise NotImplementedError
    end
  end
end
