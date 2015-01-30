require 'pathname'

module RPath
  module Adapters

    class Filesystem < RPath::Adapter

      # Always false. The filesystem adapter must be specified in calls to
      # {#RPath}.
      # @param [Object] graph
      # @return [Boolean]
      def adapts?(graph)
        false
      end

      # @param [String] vertex
      #   A filesystem path
      # @return [String]
      #   Returns the basename
      def name(vertex)
        File.basename vertex
      end

      # @param [String] vertex
      #   A filesystem path
      # @return [Array<String>]
      #   Returns the expanded paths of the directory entries. An empty array
      #   if +vertex+ is a file.
      def adjacent(vertex)
        begin
          entries = Dir.entries(File.expand_path(vertex))
        rescue SystemCallError
          return []
        end

        entries.collect { |entry| File.join(vertex, entry) }
      end

      # @param [String] vertex
      #   A filesystem path
      # @param [String, Symbol] name
      #   An attribute in {ATTRIBUTES}
      # @return [Object, nil]
      #   Returns the value of the attribute; +nil+ if the attribute is
      #   invalid.
      def attribute(vertex, name)
        if ATTRIBUTES.include?(name.to_s)
          begin
            Pathname(File.expand_path(vertex)).send(name)
          rescue SystemCallError
            nil
          end
        else
          nil
        end
      end

      # @param [String] vertex
      #   A filesystem path
      # @return [String, nil]
      #   Returns the contents if +vertex+ is a file; otherwise +nil+.
      def content(vertex)
        begin
          File.read File.expand_path(vertex)
        rescue SystemCallError
          nil
        end
      end

      # Attributes that may be passed as names to {#attribute}
      ATTRIBUTES = %w{
        blockdev?
        chardev?
        directory?
        executable?
        executable_real?
        file?
        grpowned?
        owned?
        pipe?
        readable?
        world_readable?
        readable_real?
        setgid?
        setuid?
        size
        socket?
        sticky?
        symlink?
        writable?
        world_writable?
        writable_real?
        zero?
        atime
        birthtime
        ctime
        mtime
        ftype
        readlink
        stat
        lstat
        dirname
        extname
        split }
    end

  end
end
