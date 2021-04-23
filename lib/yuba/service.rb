module Yuba
  class Service
    class_attribute :_properties
    self._properties = {}

    class << self
      def call(**args)
        service = args.empty? ? new : new(**args)
        service.call
        service
      end

      def property(name, options = {})
        self._properties = _properties.merge(name.to_sym => options)
      end
    end

    def initialize(**args)
      validate_arguments(args)
      define_accessors(args)
      success
    end

    def success
      @_success = true
    end

    def fail!
      @_success = false
    end

    def success?
      @_success
    end

    def failure?
      !@_success
    end

    def has_property?(property)
      _properties.has_key?(property.to_sym)
    end

    def has_required_property?(property)
      has_property?(property) && !_properties.dig(property.to_sym, :optional)
    end

    def has_optional_property?(property)
      has_property?(property) && !has_required_property?(property)
    end

    def has_public_property?(property)
      has_property?(property) && !has_private_property?(property)
    end

    def has_private_property?(property)
      has_property?(property) && !_properties.dig(property.to_sym, :public)
    end

    def has_value?(property)
      has_property?(property) && respond_to?(property, true) && !send(property).nil?
    end

    private

    def validate_arguments(args)
      args.each_key do |key|
        if !_properties.has_key?(key.to_sym) && !_properties.dig(key.to_sym, :optional)
          raise ArgumentError, "missing 'property :#{key}' in #{self.class.name} class"
        end
      end

      required_keys = _required_properties.keys
      missing_keys = required_keys - args.keys
      unless missing_keys.empty?
        raise ArgumentError, "missing required arguments: #{missing_keys.join(',')}"
      end
    end

    def define_accessors(args)
      args.each do |key, value|
        public_method = _properties[key.to_sym][:public]
        define_singleton_method key do
          value
        end
        self.singleton_class.class_eval { private key.to_sym } unless public_method
      end
    end

    def _required_properties
      _properties.reject { |_, value| value[:optional] }
    end
  end
end
