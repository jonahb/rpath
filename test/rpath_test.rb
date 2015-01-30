require 'test_helper'
require 'test_adapter'

class RPathTest < Test
  def setup
    RPath::Registry.clear
  end

  def test_use_adds_adapter_with_default_id
    RPath.use TestAdapter.new
    assert RPath::Registry.find(:test_adapter)
  end

  def test_use_adds_adapter_with_custom_id
    RPath.use TestAdapter.new, :test
    assert RPath::Registry.find(:test)
  end

  def test_use_adds_builtin_adapter
    RPath.use :filesystem
    assert RPath::Registry.find(:filesystem)
  end

  def test_use_raises_on_invalid_builtin_adapter
    assert_raises(RuntimeError) do
      RPath.use :non_existent
    end
  end

  def test_rpath_returns_expression_if_no_graph_provided
    RPath.use TestAdapter.new
    assert_kind_of RPath::Expression, RPath { a.b.c }
    assert_kind_of RPath::Expression, RPath { |root| root.A.B.C }
  end

  def test_rpath_evaluates_if_graph_provided
    RPath.use TestAdapter.new
    expected = 'hello'
    graph = {content: expected}

    value = RPath(graph) { |root| root.content }
    assert_equal expected, value

    value = RPath(graph) { content }
    assert_equal expected, value
  end
end
