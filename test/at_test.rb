require 'test_helper'
require 'test_adapter'
require 'vertex_expression_tests'

class AtTest < Test
  include VertexExpressionTests

  def setup
    RPath.use TestAdapter.new
  end

  def vertex_expression
    RPath::At.new(RPath { foo }, 0)
  end

  def test_eval_returns_node_at_index
    prior = RPath { |root| root.adjacent }
    exp = RPath::At.new(prior, 0)
    value = exp.eval({adjacent: [{name: 'a'}, {name: 'b'}]})
    assert_equal({name: 'a'}, value)
  end
end
