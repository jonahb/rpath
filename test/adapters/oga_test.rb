require 'test_helper'
require 'oga'

class OgaTest < Test
  attr_reader :adapter

  def setup
    @adapter = RPath::Adapters::Oga.new
  end

  def test_adapts_document
    assert adapter.adapts?(Oga::XML::Document.new)
  end

  def test_adapts_element
    assert adapter.adapts?(Oga::XML::Element.new)
  end

  def test_doesnt_adapt_string
    refute adapter.adapts?('hello')
  end

  def test_name_returns_nil_for_document
    doc = Oga.parse_xml('<root/>')
    assert_nil adapter.name(doc)
  end

  def test_name_returns_name_for_element
    doc = Oga.parse_xml('<root/>')
    assert_equal 'root', adapter.name(doc.children.first)
  end

  def test_adjacent_returns_children_for_document
    doc = Oga.parse_xml('<root><a></a><b></b><a></a></root>')
    assert_equal doc.xpath('*').to_a, adapter.adjacent(doc)
  end

  def test_adjacent_returns_children_for_element
    doc = Oga.parse_xml('<root><a></a><b></b><a></a></root>')
    assert_equal doc.xpath('root/*').to_a, adapter.adjacent(doc.children.first)
  end

  def test_attribute_returns_nil_for_document
    doc = Oga.parse_xml('<root a="b"></root>')
    assert_nil adapter.attribute(doc, :foo)
  end

  def test_attribute_returns_value_for_element
    doc = Oga.parse_xml('<root a="b"></root>')
    assert_equal 'b', adapter.attribute(doc.children.first, 'a')
  end

  def test_attribute_returns_nil_for_element_if_non_existent
    doc = Oga.parse_xml('<root a="b"></root>')
    assert_nil adapter.attribute(doc.children.first, 'z')
  end

  def test_content_returns_nil_for_document
    doc = Oga.parse_xml('<root>hello</root>')
    assert_nil adapter.content(doc)
  end

  def test_content_returns_text_for_element
    doc = Oga.parse_xml('<root>hello</root>')
    assert_equal 'hello', adapter.content(doc.children.first)
  end

  def test_expressions_on_document
    RPath.use :oga

    doc = Oga.parse_xml(<<-eof)
      <a>
        <b x='y'>
          <c>text</c>
        </b>
        <b x='z'/>
      </a>
    eof

    assert_equal doc.xpath('/a').to_a, doc.rpath { a }
    assert_equal doc.at_xpath('/a[1]'), doc.rpath { a[0] }
    assert_equal doc.at_xpath('/a/b[2]'), doc.rpath { a.b[1] }
    assert_equal doc.xpath('/a/b').to_a, doc.rpath { a.b }
    assert_equal doc.at_xpath('/a/b[1]').attr(:x).value, doc.rpath { a.b[:x] }
    assert_equal doc.at_xpath('//c').text, doc.rpath { a.b.c.content }
  end

  def test_expressions_on_element
    RPath.use :oga
    doc = Oga.parse_xml('<foo><bar baz="qux"/></foo>')
    assert_equal "qux", doc.children.first.rpath { bar[:baz] }
  end
end
