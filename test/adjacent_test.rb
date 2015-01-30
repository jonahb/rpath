require 'test_helper'
require 'test_adapter'
require 'vertex_array_expression_tests'

class AdjacentTest < Test
  include VertexArrayExpressionTests

  def setup
    RPath.use TestAdapter.new
  end

  def vertex_array_expression
    RPath::Adjacent.new(RPath::Root.new)
  end

  def test_eval_returns_adjacent
    adjacent = [vertex: {}]
    exp = RPath::Adjacent.new(RPath::Root.new)
    assert_equal adjacent, exp.eval({adjacent: adjacent})
  end

  def test_eval_returns_nil_when_prior_eval_returns_nil
    prior = RPath { |root| root.foo[0] }
    exp = RPath::Adjacent.new(prior)
    assert_nil exp.eval({})
  end
end
