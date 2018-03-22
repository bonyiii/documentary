module Documentary
  module Params
    extend ActiveSupport::Concern

    included do
      before_action :describe_params

      def self.params(action = nil, **_args, &block)
        return @store unless action

        unless public_method_defined?(action)
          raise(Documentary::PublicMethodMissing, "'#{self}' has no public instance method '#{action}' defined!")
        end

        @store ||= Store.new
        @store[action] = ParamBuilder.build(&block)
        @store
      end
    end

    def params_of(method)
      self.class.params[method.to_sym]
    end

    private

    def describe_params
      if request.headers['Describe-Params']
        respond_to do |format|
          format.json { render json: params_of(action_name) }
          format.xml { render xml: params_of(action_name) }
        end
      end
    end
  end

  class ParamBuilder
    attr_reader :store

    def self.build(&block)
      new.tap { |param_builder| param_builder.instance_eval(&block) }.store
    end

    def initialize
      @store = Store.new
    end

    def required(param, **args, &block)
      build(param, required: true, **args, &block)
    end

    def optional(param, **args, &block)
      build(param, required: false, **args, &block)
    end

    private

    def build(param, required:, type: nil, desc: nil, &block)
      store[param] = block ? self.class.build(&block) : Store.new

      store[param][:required] = required
      store[param][:type] = type.to_s if type
      store[param][:desc] = desc if desc
    end
  end
end
