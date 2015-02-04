# RPath

"Don't use this." —[flavorjones](https://github.com/flavorjones) [[1]](http://www.nokogiri.org/tutorials/searching_a_xml_html_document.html)

[![Gem Version](https://badge.fury.io/rb/rpath.svg)](http://badge.fury.io/rb/rpath)
[![Build Status](https://travis-ci.org/jonahb/rpath.svg?branch=master)](https://travis-ci.org/jonahb/rpath)

## Overview

RPath lets you query graphs, such as XML documents, with just Ruby.

RPath can operate on [Nokogiri](http://www.nokogiri.org) documents, [REXML](http://www.germane-software.com/software/rexml/) documents, and the filesystem. Building adapters for other graphs is simple.

Leading members of the Ruby community have [warned against](http://www.nokogiri.org/tutorials/searching_a_xml_html_document.html) RPath's approach. They're probably right! RPath is as much an experiment as a useful tool.

## Documentation

This README provides an overview of RPath. Full documentation is available at [rubydoc.info](http://www.rubydoc.info/gems/rpath).

## Installation

```bash
gem install rpath
```

## Example

Suppose we want the value of the `name` attribute in the following XML document:

```ruby
xml = Nokogiri::XML <<end
  <places>
    <place name="Green-Wood"/>
  </places>
end
```

First we tell RPath we'll be using Nokgiri:

```ruby
RPath.use :nokogiri
```

Then we create an RPath expression ...

```ruby
exp = RPath { places.place[:name] }
```

... and evaluate it on the document:

```ruby
exp.eval(xml) # => "Green-Wood"
```

If we only plan to use the expression once, we can pass the graph to `RPath`. RPath evaluates the expression and returns the result:

```ruby
RPath(xml) { places.place[:name] } # => "Green-Wood"
```

Some adapters, such as the built-in Nokogiri adapter, may add convenience methods that make the syntax even prettier:

```ruby
xml.rpath { places.place[:name] } # => "Green-Wood"
```

## The Graph Model

In an RPath [graph](http://en.wikipedia.org/wiki/Graph_(mathematics)),

* There is an initial vertex (a "root"),
* Each vertex has a name,
* Each vertex has zero or more adjacent vertices,
* Each vertex has zero or more named attributes, and
* Each vertex may have associated data called "content."

Adapters implement this abstraction for a particular type of graph. RPath can operate on any graph for which there is an adapter.

## Expressions

An RPath expression, given a graph, selects a value—a vertex, a vertex array, the value of an attribute, or a vertex's content. RPath expressions are constructed by chaining methods inside the block passed to `RPath`.

### Selecting Vertices

All vertices named "foo" adjacent to the root:

```ruby
RPath { foo }
```

The first "foo" adjacent to the root:

```ruby
RPath { foo[0] }
```

All vertices named "bar" adjacent to the first "foo":

```ruby
RPath { foo[0].bar }
```

Or, more succinctly (the first "foo" is assumed if the indexer is omitted):

```ruby
RPath { foo.bar }
```

_All_ vertices adjacent to the first "foo":

```ruby
RPath { foo.adjacent }
```

All vertices adjacent to the first "foo" named "adjacent" (`#named` lets us avoid collisions with built-in methods):

```ruby
RPath { foo.adjacent.named("adjacent") }
```

All "foos" with attribute "baz" equal to "qux":

```ruby
RPath { foo.where(baz: 'qux') }
```

Or simply:

```ruby
RPath { foo[baz: 'qux'] }
```

And finally, all "foos" meeting arbitrary criteria:

```ruby
RPath { foo.where { |vertex| some_predicate?(vertex) } } 
```

### Selecting Attributes

Attribute values are selected by passing a string to `#[]`:

```ruby
# The "baz" attribute of the first vertex named "foo" adjacent to the root
RPath { foo['baz'] }
```

### Selecting Content

A vertex's content is selected with `#content`:

```ruby
# The content of the first vertex named "foo" adjacent to the root
RPath { foo.content }
```

## Adapters

### Nokogiri

The Nokogiri adapter exposes XML elements as vertices and child elements as adjacent vertices:

```ruby
RPath.use :nokogiri

xml = Nokogiri::XML <<end
  <foo>
    <bar baz="qux">Hello, RPath</bar>
  </foo>
end

RPath(xml) { foo.bar[0] } # => #<Nokogiri::XML::Element ... >
```

XML attributes become RPath attributes:

```ruby
RPath(xml) { foo.bar['baz'] } # => "qux"
```

And text content is accessible with `#content`:

```ruby
RPath(xml) { foo.bar.content } # => "Hello, RPath"
```

An expression may be evaluated not just on an XML document but any `Nokogiri::XML::Node`. Non-element nodes such as processing instructions, alas, are not accessible.

Finally, the convenience method `#rpath`, added to `Nokogiri::XML::Node`, allows for more compact syntax:

```ruby
xml.rpath { foo.bar.content } # => "Hello, RPath"
```

### REXML

The REXML adapter is similar to the Nokogiri one. Expressions may be evaluated on any `REXML::Element`.

```ruby
RPath.use :rexml
xml = REXML::Document.new('<foo bar="baz"/>')
xml.rpath { foo['bar'] } # => "baz"
```

### Filesystem

The filesystem adapter exposes files and directories as vertices. Directory entries are adjacent to their directory. Expressions may be evaluated on any directory:

```ruby
RPath.use :filesystem

# Note that we must specify the adapter because RPath can't infer it from '~'
RPath('~', :filesystem) { where { |f| f =~ /bash/ } } # => ["~/.bash_history", "~/.bash_profile"]
```

Many file properties become RPath attributes:

```ruby
RPath('/', :filesystem) { etc.hostname[:mtime] } # => 2014-12-17 14:43:24 -0500
```

And file contents are accessible with `#content`:

```ruby
RPath('/', :filesystem) { etc.hostname.content } # => "jbook"
```

## Custom Adapters

Custom adapters allow RPath expressions to operate on new types of graphs. To create a custom adapter, subclass `RPath::Adapter` and implement the abstract methods `#adjacent`, `#attribute`, `#content`, and `#name`. See the implementations in `RPath::Adapters` for examples.

Once you've implemented a custom adapter, pass an instance to `#RPath`:

```ruby
RPath(graph, CustomAdapter.new) { foo.bar }
```

To avoid creating an instance for every evaluation, register the adapter and pass the underscored, symbolized class to `RPath`:

```ruby
RPath.use CustomAdapter.new
RPath(graph, :custom_adapter) { foo.bar }
```

If that's too long, pass a custom ID to `RPath.use`:

```ruby
RPath.use CustomAdapter.new, :custom
RPath(graph, :custom) { foo.bar }
```

Or, to avoid specifying the adapter altogether—as the built-in XML adapters do—implement `#adapts?` in your adapter class:

```ruby
class CustomAdapter < RPath::Adapter
  def adapts?(graph)
    graph.is_a? CustomGraph
  end
  # ...
end
```

Now RPath will select a registered `CustomAdapter` when an expression is evaluated on a `CustomGraph`:

```ruby
RPath.use CustomAdapter.new
RPath(CustomGraph.new) { foo.bar }
```

## Contributing

Please submit issues and pull requests to [jonahb/rpath](http://github.com/jonahb/rpath) on GitHub.

