module Yuba
  module Rendering
    def render(*args)
      view_model_hash = args.find { |arg| arg.is_a?(Hash) && arg[:view_model] }
      @_view_model = view_model_hash[:view_model] if view_model_hash[:view_model]
      super
    end

    def view_assigns
      super.merge(view_model_assigns)
    end

    private

    def _protected_ivars
      super.merge(:@_view_model)
    end

    def view_model_assigns
      return {} unless @_view_model
      # TODO: get all public methods between self and Yuba::ViewModel
      #       now get only in self
      methods = @_view_model.public_methods(false)
      methods.reject! do |method_name|
        %i[call initialize].include?(method_name)
      end
      methods.inject({}) do |hash, method_name|
        hash[method_name] = @_view_model.public_send(method_name)
        hash
      end
    end
  end
end
