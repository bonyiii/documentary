module Documentary
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      # req = Rack::Request.new(env)
      @request = ActionDispatch::Request.new(env)
      @response = ActionDispatch::Response.new

      if describe_params?
        prepare_response
        response.to_a
      else
        app.call(env)
      end
    end

    private

    attr_reader :app, :request, :response

    def prepare_response
      response.content_type = request.format.send(:string)
      response.body = formatted_params
    end

    def describe_params?
      request.headers['Describe-Params']
    end

    def formatted_params
      case format
      when :json
        params.to_json
      when :xml
        params.to_xml
      else
        response.status = 422
        'Not recognized format!'
      end
    end

    def format
      request.format.symbol
    end

    def params
      controller_name.constantize.params[action_name]
    end

    def recognize_path
      @recognize_path ||= Rails.application.routes.recognize_path(request.path, method: request.method)
    end

    def controller_name
      @controller ||= "#{recognize_path[:controller]}_controller".classify
    end

    def action_name
      @action_name ||= recognize_path[:action].to_sym
    end
  end
end
