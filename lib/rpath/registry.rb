module RPath

  # @private
  class Registry
    class << self
      # Registers an adapter. Once an adapter is registered, RPath calls its
      # {#adapts?} when trying to infer the adapter for an evaluation, and its
      # id, as opposed to an instance, may be given to {#RPath}.
      # @param [Adapter] adapter
      # @param [Symbol, nil] id
      #   An id that can later be passed to {#RPath}. If omitted, the
      #   symbolized, underscored name of the adapter class is assumed.
      # @return [void]
      def register(adapter, id = nil)
        id ||= default_id(adapter)
        id_to_adapter[id] = adapter
      end
      alias_method :use, :register

      # Infers the adapter for a given graph. The first adapter whose
      # {#adapts?} returns +true+ is chosen.
      # @param [Object] graph
      # @return [Adapter, nil]
      def infer(graph)
        id_to_adapter.each_value.find { |adapter| adapter.adapts?(graph) }
      end

      # Finds a registered adapter by id.
      # @param [Symbol] id
      # @return [Adapter, nil]
      def find(id)
        id_to_adapter[id]
      end

      # Unregisters all adapters
      def clear
        id_to_adapter.clear
      end

      private

      def id_to_adapter
        @id_to_adapter ||= {}
      end

      def default_id(adapter)
        Util.underscore(adapter.class.name.split('::').last).to_sym
      end
    end
  end

end
