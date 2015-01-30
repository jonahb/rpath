require 'test_helper'
require 'vertex_expression_tests'
require 'test_adapter'

class RootTest < Test
  include VertexExpressionTests

  def setup
    RPath.use TestAdapter.new
  end

  def vertex_expression
    RPath::Root.new
  end

  def test_eval_returns_graph
    graph = {}
    assert_equal graph, RPath::Root.new.eval(graph)
  end
end
