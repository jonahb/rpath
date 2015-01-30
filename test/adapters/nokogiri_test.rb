require 'test_helper'
require 'nokogiri'

class NokogiriTest < Test
  attr_reader :adapter

  def setup
    @adapter = RPath::Adapters::Nokogiri.new
  end

  def test_adapts_document
    assert adapter.adapts?(Nokogiri::XML::Document.new)
  end

  def test_doesnt_adapt_string
    refute adapter.adapts?('hello')
  end

  def test_name_returs_node_name
    doc = Nokogiri::XML('<root/>')
    assert_equal 'root', adapter.name(doc.root)
  end

  def test_adjacent_returns_children
    doc = Nokogiri::XML('<root><a></a><b></b><a></a></root>')
    assert_equal doc.xpath('/root/*').to_a, adapter.adjacent(doc.root)
  end

  def test_attribute_returns_value
    doc = Nokogiri::XML('<root a="b"></root>')
    assert_equal 'b', adapter.attribute(doc.root, 'a')
  end

  def test_attribute_returns_nil_if_non_existent
    doc = Nokogiri::XML('<root a="b"></root>')
    assert_nil adapter.attribute(doc.root, 'z')
  end

  def test_content_returns_text
    doc = Nokogiri::XML('<root>hello</root>')
    assert_equal 'hello', adapter.content(doc.root)
  end

  def test_expressions
    RPath.use :nokogiri

    doc = Nokogiri::XML(<<-eof)
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
    assert_equal doc.at_xpath('/a/b[1]')['x'], doc.rpath { a.b[:x] }
    assert_equal doc.at_xpath('//c').text, doc.rpath { a.b.c.content }
  end
end
