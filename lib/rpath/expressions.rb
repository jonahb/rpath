module RPath

  # An RPath expression, given a graph, produces a value: a vertex, a vertex
  # array, an attribute value, or a vertex's content.
  # @abstract
  class Expression

    # Evaluates the expression on a graph
    # @param [Object] graph
    # @param [RPath::Adapter, Symbol, nil] adapter
    #   An {Adapter} instance, the id symbol given when the adapter was
    #   registered with {RPath.use}, or +nil+ if the adapter should be
    #   inferred.
    # @return [Object]
    # @raise [RuntimeError]
    #   The adapter can't be determined
    # @ raise [ArgumentError]
    #   +adapter+ is not an {Adapter}, Symbol, or nil
    # @see #RPath
    # @see RPath.use
    #
    def eval(graph, adapter = nil)
      adapter = case adapter
      when RPath::Adapter
        adapter
      when Symbol
        Registry.find adapter.to_sym
      when nil
        Registry.infer graph
      else
        raise ArgumentError, "Adapter must be an RPath::Adapter, Symbol, or nil"
      end

      unless adapter
        raise "Can't determine adapter"
      end

      do_eval graph, adapter
    end

    private

    def do_eval(graph, adapter)
      raise NotImplementedError
    end
  end


  # An expression that evaluates to a vertex V
  # @abstract
  class VertexExpression < Expression
    # Returns an expression that evaluates to V's adjacent vertices.
    # @return [Adjacent]
    def adjacent
      Adjacent.new self
    end

    # Returns an expression that evaluates to V's content.
    # @return [Content]
    def content
      Content.new self
    end

    # Returns an expression that evaluates to the value of an attribute of V
    # @return [Attribute]
    # @raise [ArgumentError]
    #   +subscript+ is not a String or Symbol
    def [](subscript)
      unless subscript.is_a?(String) || subscript.is_a?(Symbol)
        raise ArgumentError, "Subscript for expression producing a vertex must by a String or Symbol"
      end
      Attribute.new self, subscript
    end

    # Returns an expression that evaluates to V's adjacent vertices named
    # +name+. Enables the basic RPath expression +RPath { foo }+.
    # @return [Named]
    def method_missing(name, *args, &block)
      Named.new adjacent, name.to_s
    end
  end


  # An expression that evaluates to a vertex array A
  # @abstract
  class VertexArrayExpression < Expression
    # Returns an expression that evaluates to the vertices in A meeting certain
    # conditions.
    # @return [Where]
    # @see Where#initialize
    def where(*args, &block)
      Where.new self, *args, &block
    end

    # Returns an expression that evaluates to the vertices in A named +name+.
    # @param [String] name
    # @return [Named]
    def named(name)
      Named.new self, name
    end

    # @overload [](index)
    #   Returns an expression that evaluates to the vertex at index +index+ in
    #   A.
    #   @param [Integer] index
    #   @return [At]
    # @overload [](conditions)
    #   Returns an expression that evaluates to the vertices in A meeting
    #   certain conditions.
    #   @param [Hash] conditions
    #   @return [Where]
    #   @see Where#initialize
    # @overload [](attribute)
    #   Returns an expression that evaluates to the value of an attribute of
    #   the first vertex in A. Enables omitting the indexer in
    #   +RPath { foo['bar'] }+
    #   @param [String, Symbol] attribute
    #   @return [Attribute]
    # @raise [ArgumentError]
    #   +subscript+ is not an Integer, Hash, String, or Symbol
    def [](subscript)
      case subscript
      when Integer
        At.new self, subscript
      when Hash
        Where.new self, subscript
      when String, Symbol
        self[0][subscript]
      else
        raise ArgumentError, "Subscript for expression producing a vertex must be an Integer, Hash, String, or Symbol"
      end
    end

    # Constructs an {At} that evaluates to the first vertex in A;
    # forwards the method invocation to this {At}. Enables omitting
    # the indexer in expressions like +RPath { foo.bar }+.
    def method_missing(name, *args, &block)
      self[0].send name, *args, &block
    end
  end    


  # Evaluates to the root of the graph.
  class Root < VertexExpression
    # @return [String]
    def to_s
      'root'
    end

    private

    def do_eval(graph, adapter)
      adapter.root graph
    end
  end


  # Given a prior expression producing vertex V, evaluates to an array
  # containing V's adjacent vertices.
  class Adjacent < VertexArrayExpression
    # @param [Expression] prior
    #   An expression that evaluates to a vertex 
    def initialize(prior)
      super()
      @prior = prior
    end

    # @return [String]
    def to_s
      "#{@prior}."
    end

    private

    def do_eval(graph, adapter)
      vertex = @prior.eval(graph, adapter)
      vertex && adapter.adjacent(vertex)
    end
  end


  # Given a prior expression producing vertex array A, evaluates to an array
  # containing the vertices in A with a certain name.
  class Named < VertexArrayExpression
    # @param [Expression] prior
    #   An expression that evaluates to a vertex array
    # @param [String] name
    def initialize(prior, name)
      super()
      @prior = prior
      @name = name
    end

    # @return [String]
    def to_s
      "#{@prior}#{@name}"
    end

    private

    def do_eval(graph, adapter)
      vertices = @prior.eval(graph, adapter)
      vertices && vertices.select { |vertex| @name == adapter.name(vertex) }
    end
  end


  # Given a prior expression producing vertex array A, evaluates to an array
  # containing the vertices in A that match certain conditions.
  class Where < VertexArrayExpression
    # @overload initialize(prior, conditions)
    #   @param [Expression] prior
    #     An expression that evaluates to a vertex array
    #   @param [Hash{Symbol => Object}] conditions
    #     A map of attribute keys to values.
    # @overload initialize(prior)
    #   @param [Expression] prior
    #     An expression that evaluates to a vertex array
    #   @yieldparam vertex [Object]
    #   @yieldreturn [Boolean]
    #     Whether the vertex should be selected
    def initialize(prior, conditions = {}, &selector)
      super()
      @prior = prior
      @selector = block_given? ? selector : nil
      @conditions = block_given? ? nil : conditions
    end

    # @return [String]
    def to_s
      conditions = @selector ?
        'selector' :
        @conditions.map { |k, v| "#{k}: #{v}" }.join(', ')

      "#{@prior}[#{conditions}]"
    end

    private

    def do_eval(graph, adapter)
      vertices = @prior.eval(graph, adapter)
      return nil unless vertices

      if @selector
        vertices.select(&@selector)
      else
        vertices.select do |vertex|
          @conditions.all? do |name, value|
            adapter.attribute(vertex, name) == value
          end
        end
      end
    end
  end


  # Given a prior expression producing vertex array A, evaluates to the vertex
  # in A at a given index.
  class At < VertexExpression
    # @param [Expression] prior
    #   An expression that evaluates to a vertex array
    # @param [Integer] index
    #   The index of the vertex to produce
    def initialize(prior, index)
      super()
      @prior = prior
      @index = index
    end

    # @return [String]
    def to_s
      "#{@prior}[#{@index}]"
    end

    private

    def do_eval(graph, adapter)
      vertices = @prior.eval(graph, adapter)
      vertices && vertices[@index]
    end
  end


  # Given a prior expression producing a vertex V, evaluates to the value of
  # the attribute of V with the given name.
  class Attribute < Expression
    # @param [Expression] prior
    #   An expression that evaluates to a vertex
    # @param [String] name
    #   The name of the attribute
    def initialize(prior, name)
      super()
      @prior = prior
      @name = name
    end

    # @return [String]
    def to_s
      "#{@prior}[#{@name}]"
    end

    private

    def do_eval(graph, adapter)
      vertex = @prior.eval(graph, adapter)
      vertex && adapter.attribute(vertex, @name)
    end
  end


  # Given a prior expression producing vertex V, evaluates to V's content.
  class Content < Expression
    # @param [Expression] prior
    #   An expression producing a vertex
    def initialize(prior)
      @prior = prior
    end

    # @return [String]
    def to_s
      "#{@prior}:content"
    end

    private

    def do_eval(graph, adapter)
      vertex = @prior.eval(graph, adapter)
      vertex && adapter.content(vertex)
    end
  end

end
