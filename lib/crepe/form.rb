module Crepe
  class Form
    autoload :Attribute, 'crepe/form/attribute'
    autoload :Attributes, 'crepe/form/attributes'
    autoload :Collection, 'crepe/form/collection'

    include ActiveModel::Model
    class_attribute :_model_attribute
    class_attribute :attributes

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
      attributes[name] = value
    end
  end
end
