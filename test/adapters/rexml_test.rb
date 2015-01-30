require 'test_helper'
require 'rexml/document'

class REXMLTest < Test
  attr_reader :adapter

  def setup
    @adapter = RPath::Adapters::REXML.new
  end

  def test_adapts_document
    assert adapter.adapts?(REXML::Document.new)
  end

  def test_doesnt_adapt_string
    refute adapter.adapts?('hello')
  end

  def test_name_returns_node_name
    doc = REXML::Document.new('<root/>')
    assert_equal 'root', adapter.name(doc.root)
  end

  def test_adjacent_returns_children
    doc = REXML::Document.new('<root><a></a><b></b><a></a></root>')
    assert_equal REXML::XPath.match(doc, '/root/*'), adapter.adjacent(doc.root)
  end

  def test_attribute_returns_value
    doc = REXML::Document.new('<root a="b"></root>')
    assert_equal 'b', adapter.attribute(doc.root, 'a')
  end

  def test_attribute_returns_nil_if_non_existent
    doc = REXML::Document.new('<root a="b"></root>')
    assert_nil adapter.attribute(doc.root, 'z')
  end

  def test_content_returns_text
    doc = REXML::Document.new('<root>hello</root>')
    assert_equal 'hello', adapter.content(doc.root)
  end

  def test_expressions
    RPath.use :rexml

    doc = REXML::Document.new(<<-eof)
      <a>
        <b x='y'>
          <c>text</c>
        </b>
        <b x='z'/>
      </a>
    eof

    assert_equal REXML::XPath.match(doc, '/a').to_a, doc.rpath { a }
    assert_equal REXML::XPath.first(doc, '/a[1]'), doc.rpath { a[0] }
    assert_equal REXML::XPath.first(doc, '/a/b[2]'), doc.rpath { a.b[1] }
    assert_equal REXML::XPath.match(doc, '/a/b').to_a, doc.rpath { a.b }
    assert_equal REXML::XPath.first(doc, '/a/b[1]').attributes['x'], doc.rpath { a.b[:x] }
    assert_equal REXML::XPath.first(doc, '//c').text, doc.rpath { a.b.c.content }
  end
end
