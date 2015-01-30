require 'test_helper'
require 'test_adapter'

class AttributeTest < Test
  def setup
    RPath.use TestAdapter.new
  end

  def test_eval_returns_attribute_value
    expected = 'hello'
    nodes = {attr: expected}
    expression = RPath::Attribute.new(RPath::Root.new, :attr)
    value = expression.eval(nodes)
    assert_equal expected, value
  end

  def test_eval_returns_nil_if_prior_returns_nil
    expression = RPath::Attribute.new(RPath::At.new(RPath::Root.new, 0), :attr)
    assert_nil expression.eval({children:[]})
  end
end
