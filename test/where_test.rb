require 'test_helper'
require 'vertex_array_expression_tests'
require 'test_adapter'

class WhereTest < Test
  include VertexArrayExpressionTests

  def setup
    RPath.use TestAdapter.new
  end

  def vertex_array_expression
    prior = RPath { |root| root.adjacent }
    RPath::Where.new(prior, {})
  end

  def test_eval_with_selector_returns_matching_vertices
    graph = {adjacent: [{name: 'a'}, {name: 'a'}, {name: 'b'}, {name: 'c'}]}
    prior = RPath { |root| root.adjacent }
    exp = RPath::Where.new(prior) { |v| v[:name] == 'a' }
    assert_equal [{name: 'a'}, {name: 'a'}], exp.eval(graph)
  end

  def test_eval_with_conditions_returns_matching_vertices
    graph = {adjacent: [{name: 'a', id: 1}, {name: 'a', id: 2}]}
    prior = RPath { |root| root.adjacent }
    exp = RPath::Where.new(prior, name: 'a', id: 2)
    assert_equal [{name: 'a', id: 2}], exp.eval(graph)
  end

  def test_eval_returns_nil_if_prior_returns_nil
    prior = RPath { |root| root.foo[0] }
    exp = RPath::Where.new(prior, {})
    assert_nil exp.eval({})
  end
end
