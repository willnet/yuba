module Yuba
  class ViewModel
    class_attribute :_properties
    self._properties = {}

    class << self
      def property(name, options = {})
        _properties[name.to_sym] = options
      end
    end

    def initialize(**args)
      validate_arguments(args)
      define_accessors(args)
    end

    private

    def validate_arguments(args)
      args.each_key do |key|
        if !_properties.has_key?(key.to_sym) && !_properties.dig(key.to_sym, :optional)
          raise ArgumentError, "missing 'property :#{key}' in #{self.class.name} class"
        end
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
  end
end
