%w{
  adapter
  adapters
  expressions
  registry
  util
  version
}.each do |file|
  require "rpath/#{file}"
end

module RPath
  class << self
    # Registers an adapter. Once an adapter is registered, RPath calls its
    # {Adapter#adapts?} when trying to infer the adapter for an evaluation,
    # and its id may be given to {#RPath}.
    # @example Built-in adapter
    #   RPath.use :nokogiri
    # @example Custom adapter
    #   RPath.use CustomAdapter.new
    #   RPath(graph, :custom_adapter) { foo.bar }
    # @example Custom adapter with custom ID
    #   RPath.use CustomAdapter.new, :custom
    #   RPath(graph, :custom) { foo.bar }
    # @param [Symbol, Adapter] adapter
    #   For built-in adapters, the underscored, symbolized class name (e.g.
    #   +:nokogiri+). For custom adapters, an instance of the adapter class.
    # @param [Symbol, nil] id
    #   The identifier to be used in calls to {#RPath}. If +nil+, the
    #   underscored, symbolized name of the adapter class is assumed.
    # @return [void]
    #
    def use(adapter, id = nil)
      if adapter.is_a?(Symbol)
        class_names = [Util.camelcase(adapter.to_s), adapter.to_s.upcase]
        class_ = Util.first_defined_const(RPath::Adapters, *class_names)

        unless class_
          raise "No adapter in RPath::Adapters with class name in #{class_names}"
        end

        adapter = class_.new
      end

      Registry.register adapter, id
    end
    alias_method :register, :use
  end
end

# Constructs an RPath expression and optionally evaluates it on a graph.
#
# @overload RPath
#   Constructs an RPath expression
#   @example Construct an expression
#     exp = RPath { foo.bar }
#   @example Construct an expression beginning with an uppercase letter
#     exp = RPath { |root| root.Users.alice }
#   @yieldparam [RPath::Root] root
#     The {RPath::Root} of the RPath expression. You should almost
#     always omit this yield paramter. Use it only to avoid an exception if the
#     first letter of your expression is uppercase. See the example above.
#   @return [RPath::Expression]
#   @see file:README.md
#
# @overload RPath(graph, adapter = nil)
#   Constructs an RPath expression, evaluates it, and returns the result
#   @example Construct and expression and evaluate it on an XML document
#     RPath.use :nokogiri
#     xml = Nokogiri::XML('<foo bar="baz"/>')
#     RPath(xml) { foo['bar'] } # => "baz"
#   @example Construct an expression and evaluate it with a custom adapter
#     RPath(graph, CustomAdapter.new) { foo.bar }
#   @example Construct an expression and evaluate it with a custom adapter that has been registered
#     RPath(graph, :custom) { foo.bar }
#   @example Construct an expression and evaluate it, letting RPath infer the adapter
#     RPath(graph) { foo.bar }
#   @param [Object] graph
#     The graph on which to evaluate the expression.
#   @param [RPath::Adapter, Symbol, nil] adapter
#     The adapter with which to evaluate the expression. If the adapter has been
#     registered with {RPath.use}, its id (a symbol) may be given as a 
#     shortcut. If +nil+, RPath attempts to infer the adapter by calling
#     {RPath::Adapter#adapts?} on registered adapters.
#   @yieldparam [RPath::Root] root
#     The {RPath::Root} of the RPath expression. You should almost
#     always omit this yield parameter. Use it only to avoid an exception if the
#     first letter of your expression is uppercase. See the example above.
#   @return [Object]
#   @see file:README.md
#   @see RPath.use
#
def RPath(graph = nil, adapter = nil, &block)
  exp = RPath::Root.new

  if block_given?
    exp = block.arity > 0 ? block.call(exp) : exp.instance_eval(&block)
  end

  graph ? exp.eval(graph, adapter) : exp
end
