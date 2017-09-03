module Yuba
  class Form
    autoload :Attribute, 'yuba/form/attribute'
    autoload :Attributes, 'yuba/form/attributes'
    autoload :Collection, 'yuba/form/collection'

    include ActiveModel::Model
    class_attribute :_model_attribute
    class_attribute :attributes
    self.attributes = {}

    class << self
      # TODO: reformのようにネストできるようにしたい
      def attribute(name, type: 'string', &block)
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

      def collection(name)
      end

      def model(name)
        self._model_attribute = name
      end

      def build(**args)
        new(**args)
      end
    end

    def initialize(value)
      yield if block_given?
      deep_assign(self.class.attributes, value)
    end

    def save
      valid? && persist
    end

    def persist
    end

    def model
      send(_model_attribute)
    end

    def model_name
      model&.model_name
    end

    private

    def write_attribute(name, value, block)
      # TODO: convert value by type of attribute
      value = Attributes.new(value, &block) if block
      self.class.attributes[name] = value
    end

    def deep_assign(attrs, value)
      raise ArgumentError unless value.is_a? Hash
      value.each do |k,v|
        if v.is_a? Hash
          attrs[k.to_s] = {}
          deep_assign(attrs[k.to_s], v)
        else
          attrs[k.to_s] = v
        end
      end
    end
  end
end
