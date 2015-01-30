require 'test_helper'

class ExpressionTest < Test

  class TestAdapter < RPath::Adapter
    def adapts?(graph)
      graph.is_a? String
    end
  end

  class TestExpression < RPath::Expression
    def do_eval(graph, adapter)
      [graph, adapter]
    end
  end

  def setup
    RPath::Registry.clear
  end

  def test_eval_uses_adapter_object
    expected = TestAdapter.new
    _, adapter = TestExpression.new.eval(nil, expected)
    assert_equal expected, adapter
  end

  def test_eval_finds_adapter
    RPath.use :filesystem
    _, adapter = TestExpression.new.eval(nil, :filesystem)
    assert adapter.is_a?(RPath::Adapters::Filesystem)
  end

  def test_eval_infers_adapter
    RPath.use TestAdapter.new
    _, adapter = TestExpression.new.eval("hello")
    assert adapter.is_a?(TestAdapter)
  end

  def test_eval_raises_if_cant_infer_adapter
    assert_raises(RuntimeError) do
      TestExpression.new.eval "no adapters"
    end
  end

end
