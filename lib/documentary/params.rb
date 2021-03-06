module Documentary
  module Params
    extend ActiveSupport::Concern

    included do
      before_action :describe_params, if: :describe_params?

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

    def authorized_params(action)
      self.class.params[action.to_sym]&.authorized_params(self)
    end

    private

    def describe_params?
      request.headers['Describe-Params']
    end

    def describe_params
      respond_to do |format|
        format.json { render json: authorized_params(action_name) }
        format.xml { render xml: authorized_paramsf(action_name) }
      end
    end
  end

  class ParamBuilder
    VALID_OPTIONS = [:authorized].freeze # :nodoc:
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

    def build(param, required:, type: nil, desc: nil, **args, &block)
      args.each_key do |k|
        unless VALID_OPTIONS.include?(k)
          raise ArgumentError.new("Unknown key for Documentary param: #{k.inspect}. Valid keys are: #{VALID_OPTIONS.map(&:inspect).join(', ')}.")
        end
      end
      store[param] = block ? self.class.build(&block) : Store.new

      store[param][:required] = required
      store[param][:type] = type.to_s if type
      store[param][:desc] = desc if desc
      store[param][:authorized] = args[:authorized] if args[:authorized]
    end
  end
end
