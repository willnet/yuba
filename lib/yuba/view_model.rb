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
      args.keys.each do |key|
        if !_properties.has_key?(key.to_sym) && !_properties.dig(key.to_sym, :optional)
          raise ArgumentError, "missing 'property :#{key}' in #{self.class.name} class"
        end
      end

      args.each do |key, value|
        define_singleton_method key do
          value
        end
      end
    end
  end
end
