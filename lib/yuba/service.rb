module Yuba
  class Service
    class_attribute :_properties
    self._properties = {}

    class << self
      def call(**args)
        return new.call if args.empty?

        new(**args).call
      end

      def property(name, options = {})
        _properties[name.to_sym] = options
      end
    end

    def initialize(**args)
      args.keys.each do |key|
        unless _properties.has_key?(key.to_sym)
          raise ArgumentError, "missing 'property :#{key}' in #{self.class.name} class"
        end
      end

      args.each do |key, value|
        define_singleton_method key do
          value
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
