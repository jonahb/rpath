module RPath

  # @private
  module Util
    class << self
      def underscore(string)
        string.gsub(/([^A-Z])([A-Z])/, '\1_\2').downcase
      end

      def camelcase(string)
        string.gsub(/(?:^|_)([a-z])/) { $1.upcase }
      end

      def first_defined_const(module_, *consts)
        const = consts.find { |c| module_.const_defined?(c) }
        const && module_.const_get(const)
      end
    end
  end

end
