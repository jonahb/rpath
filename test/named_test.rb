require 'test_helper'
require 'vertex_array_expression_tests'
require 'test_adapter'

class NamedTest < Test
  include VertexArrayExpressionTests

  def setup
    RPath.use TestAdapter.new
  end

  def vertex_array_expression
    RPath::Named.new(RPath::Adjacent.new(RPath::Root.new), 'foo')
  end

  def test_eval_returns_vertices_with_name
    graph = {adjacent: [{name: 'a'}, {name: 'b'}]}
    exp = RPath::Named.new(RPath::Adjacent.new(RPath::Root.new), 'a')
    assert_equal [{name: 'a'}], exp.eval(graph)
  end

  def test_eval_returns_nil_when_prior_eval_returns_nil
    prior = RPath { |root| root.foo[0].adjacent }
    exp = RPath::Named.new(prior, 'a')
    assert_nil exp.eval({})
  end
end
