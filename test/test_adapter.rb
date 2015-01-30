class TestAdapter < RPath::Adapter

  def adapts?(object)
    object.is_a?(Hash) || object.is_a?(Array)
  end

  def name(vertex)
    vertex[:name]
  end

  def adjacent(vertex)
    vertex[:adjacent] || []
  end

  def attribute(vertex, name)
    vertex[name]
  end

  def content(vertex)
    vertex[:content]
  end

end
