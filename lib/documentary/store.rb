module Documentary
  # A hash like class that is able to convert params
  # to strong parameters
  class Store < Hash
    def to_strong
      recursive_each(self)
    end

    def authorized_params(controller)
      dup.tap { |store| (store.delete_unauthorized(controller)) }
    end

    protected

    def delete_unauthorized(controller)
      delete_if do |k, v|
        next unless v.instance_of?(Store)
        (v[:if] && !evaluate_if(v[:if], controller)) || v.delete_unauthorized(controller).empty?
      end
    end

    private

    def evaluate_if(symbol_or_proc, controller)
      return symbol_or_proc.call(controller) if symbol_or_proc.respond_to?(:call)
      return controller.send(symbol_or_proc) if symbol_or_proc.is_a?(Symbol)
    end

    def recursive_each(hash)
      hash.map do |key, value|
        if nested?(value)
          { key => recursive_each(value) }
        else
          if value.is_a?(Hash)
            if value[:type] == Array.to_s
              { key => [] }
            else
              key
            end
          end
        end
      end.compact
    end

    def nested?(value)
      value.is_a?(Hash) && !(value.keys - %i[type desc required if]).empty?
    end
  end
end
