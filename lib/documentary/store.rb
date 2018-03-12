module Documentary
  # A hash like class that is able to convert params
  # to strong parameters
  class Store < Hash
    def to_strong
      recursive_each(self)
    end

    private

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
      value.is_a?(Hash) && !(value.keys - %i[type desc required]).empty?
    end
  end
end
