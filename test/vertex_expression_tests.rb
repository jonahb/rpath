module VertexExpressionTests
  def vertex_expression
    raise NotImplementedError
  end

  def test_content_returns_content_expression
    exp = vertex_expression
    content = exp.content
    assert_kind_of RPath::Content, content
    assert_equal exp, content.instance_variable_get(:@prior)
  end

  def test_adjacent_returns_adjacent_expression
    exp = vertex_expression
    adjacent = exp.adjacent
    assert_kind_of RPath::Adjacent, adjacent
    assert_equal exp, adjacent.instance_variable_get(:@prior)
  end

  def test_subscript_returns_attribute_named_expression
    exp = vertex_expression
    name = 'attr'
    attribute = exp[name]
    assert_kind_of RPath::Attribute, attribute
    assert_equal exp, attribute.instance_variable_get(:@prior)
    assert_equal name, attribute.instance_variable_get(:@name)
  end

  def test_missing_method_returns_adjacent_and_named_expression
    exp = vertex_expression

    named = exp.child
    assert_kind_of RPath::Named, named
    assert_equal('child', named.instance_variable_get(:@name))

    adjacent = named.instance_variable_get(:@prior)
    assert_kind_of RPath::Adjacent, adjacent
    assert_equal exp, adjacent.instance_variable_get(:@prior)
  end
end
