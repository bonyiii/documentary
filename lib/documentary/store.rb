module Documentary
  # A hash like class that is able to convert params
  # to strong parameters
  class Store < Hash
    def to_strong
      convert_to_stong_param(self)
    end

    def authorized_params(controller)
      dup.tap { |store| (store.delete_unauthorized(controller)) }
    end

    protected

    def delete_unauthorized(controller)
      delete_if do |k, v|
        next unless v.instance_of?(Store)
        (v[:authorized] && !evaluate_if(v.delete(:authorized), controller)) || v.delete_unauthorized(controller).empty?
      end
    end

    private

    def evaluate_if(symbol_or_proc, controller)
      return symbol_or_proc.call(controller) if symbol_or_proc.respond_to?(:call)
      return controller.send(symbol_or_proc) if symbol_or_proc.is_a?(Symbol)
    end

    def convert_to_stong_param(hash)
      hash.map do |key, value|
        if nested?(value)
          { key => convert_to_stong_param(value) }
        elsif value.is_a?(Hash)
          value[:type] == Array.to_s ? { key => [] } : key
        end
      end.compact
    end

    def nested?(value)
      value.is_a?(Hash) && !(value.keys - %i[type desc required if]).empty?
    end
  end
end
