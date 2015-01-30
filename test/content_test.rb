require 'test_helper'
require 'test_adapter'

class ContentTest < Test
  def setup
    RPath.use TestAdapter.new
  end

  def test_eval_returns_content
    expected = 'content'
    node = {content: expected}
    expression = RPath::Content.new(RPath::Root.new)
    value = expression.eval(node)
    assert_equal expected, value
  end

  def test_eval_returns_nil_if_prior_returns_nil
    prior = RPath { |root| root.foo[0] }
    exp = RPath::Content.new(prior)
    assert_nil exp.eval({})
  end
end
