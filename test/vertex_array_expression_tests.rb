module VertexArrayExpressionTests
  def vertex_array_expression
    raise NotImplementedError
  end

  def test_subscript_with_integer_returns_at_expression
    exp = vertex_array_expression
    index = 0
    at = exp[index]
    assert_kind_of RPath::At, at
    assert_equal exp, at.instance_variable_get(:@prior)
    assert_equal index, at.instance_variable_get(:@index)
  end

  def test_subscript_with_string_returns_at_and_attribute_expressions
    exp = vertex_array_expression
    attr = 'attr'

    attribute = exp[attr]
    assert_kind_of RPath::Attribute, attribute
    assert_equal attr, attribute.instance_variable_get(:@name)
    assert_kind_of RPath::At, attribute.instance_variable_get(:@prior)

    at = attribute.instance_variable_get(:@prior)
    assert_kind_of RPath::At, at
    assert_equal 0, at.instance_variable_get(:@index)
    assert_equal exp, at.instance_variable_get(:@prior)
  end

  def test_subscript_with_hash_returns_where_expression
    exp = vertex_array_expression
    conditions = {attr: :value}
    where = exp[conditions]
    assert_kind_of RPath::Where, where
    assert_equal conditions, where.instance_variable_get(:@conditions)
    assert_equal exp, where.instance_variable_get(:@prior)
  end

  def test_where_with_block_returns_where_expression_with_selector
    exp = vertex_array_expression
    selector = lambda { |vertex| vertex['foo'] == 'bar' }
    where = exp.where(&selector)
    assert_kind_of RPath::Where, where
    assert_equal selector, where.instance_variable_get(:@selector)
    assert_equal exp, where.instance_variable_get(:@prior)
  end

  def test_where_with_hash_returns_where_expression_with_conditions
    exp = vertex_array_expression
    conditions = {attr: :value}
    where = exp.where(conditions)
    assert_kind_of RPath::Where, where
    assert_equal conditions, where.instance_variable_get(:@conditions)
    assert_equal exp, where.instance_variable_get(:@prior)
  end

  def test_named_returns_named_expression
    exp = vertex_array_expression
    named = exp.named('foo')
    assert_kind_of RPath::Named, named
    assert_equal 'foo', named.instance_variable_get(:@name)
    assert_equal exp, named.instance_variable_get(:@prior)
  end

  def test_method_missing_returns_at_and_adjacent_and_named_expression
    exp = vertex_array_expression

    named = exp.child
    assert_kind_of RPath::Named, named
    assert_equal('child', named.instance_variable_get(:@name))

    adjacent = named.instance_variable_get(:@prior)
    assert_kind_of RPath::Adjacent, adjacent

    at = adjacent.instance_variable_get(:@prior)
    assert_kind_of RPath::At, at
    assert_equal 0, at.instance_variable_get(:@index)
    assert_equal exp, at.instance_variable_get(:@prior)
  end
end
