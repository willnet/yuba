module Yuba
  class Form
    class Attributes
      class_attribute :attributes
      self.attributes = {}

      def initialize(value)
        yield if block_given?
        deep_assign(attributes, value)
      end

      def attribute(name, type: string, &block)
        mod = Module.new do
          define_method(name) do
            attributes[name.to_s]
          end
          define_method("#{name}=") do |value|
            write_attribute(name.to_s, value, block)
          end
        end
        include mod
      end

      private

      def write_attribute(name, value, block)
        # TODO: convert value by type of attribute
        value = Attributes.new(value, &block) if block
        attributes[name] = value
      end

      def deep_assign(attrs, value)
        raise ArgumentError unless value.is_a? Hash
        value.each do |k,v|
          if v.is_a? Hash
            deep_assign(attrs[k.to_s], v)
          else
            attrs[k.to_s] = v
          end
        end
      end
    end
  end
end
