module Documentary
  module Params
    def params(action = nil, **_args, &block)
      return @params unless action

      unless public_method_defined?(action)
        raise(Documentary::PublicMethodMissing, "'#{self}' has no public instance method '#{action}' defined!")
      end

      @params ||= {}
      @params[action] = ParamBuilder.build(&block)
      @params
    end

    def to_strong(action)
      recursive_each(@params[action])
    end

    def recursive_each(hash)
      hash.map do |key, value|
        if nested_hash?(value)
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

    def nested_hash?(value)
      value.is_a?(Hash) && !(value.keys - %i[type desc required]).empty?
    end
  end

  class ParamBuilder
    attr_reader :hash

    def self.build(&block)
      new.tap { |param_builder| param_builder.instance_eval(&block) }.hash
    end

    def initialize
      @hash = {}
    end

    def required(param, **args, &block)
      build(param, required: true, **args, &block)
    end

    def optional(param, **args, &block)
      build(param, required: false, **args, &block)
    end

    private

    def build(param, required:, type: 'Any', desc: nil, &block)
      hash[param] = if block
                      self.class.build(&block)
                    else
                      {}
                    end
      hash[param][:type] = type.to_s
      hash[param][:desc] = desc
      hash[param][:required] = required
    end
  end
end
