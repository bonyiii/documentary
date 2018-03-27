module Documentary
  # A hash like class that is able to convert params
  # to strong parameters
  class Store < Hash
    def to_strong
      recursive_each(self)
    end

    def authorized
      dup.tap { |store| make_sure_top_level_keys_included(store.delete_unauthorized) }
    end

    protected

    def delete_unauthorized
      delete_if do |k, v|
        next unless v.instance_of?(Store)
        (v[:if] && !v[:if].call) || v.delete_unauthorized.empty?
      end
    end

    private

    def make_sure_top_level_keys_included(allowed_params)
      each_key do |key|
        allowed_params[key] = Store.new unless allowed_params[key]
      end
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
