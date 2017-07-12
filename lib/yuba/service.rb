module Yuba
  class Service
    class << self
      def call(**args)
        service = new
        return_value = args.present? ? service.call(**args) : service.call
        if return_value.respond_to?(:success?)
          return_value
        else
          result.success(form: service.form)
        end
      end
    end

    def build_form(**args)
      form_class.build(**args)
    end

    def form_class
      Object.const_get(form_class_name)
    end

    def view_model_class
      Object.const_get(form_class_name)
    end

    private

    def form_class_name
      self.class.name.sub(/::.+Service/, 'Form')
    end

    def view_model_class_name
      self.class.name.sub(/Service\z/, 'ViewModel')
    end
  end
end
