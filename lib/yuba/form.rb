module Yuba
  class Form
    def initialize(model:)
    end

    class Attributes < ::Hash
      def add(name, options, &block)
        self[name] = if block
          NestedAttributeBuilder.call(name, options, block).new
        else
          Attribute.new(name, options)
        end
      end
    end

    class Attribute
      attr_accessor :name, :value, :options

      def initialize(name, options)
        @name = name
        @options = options
      end
    end

    NestedAttributeBuilder = ->(name, options, block) do
      Class.new do
        extend Schema
        class_eval(&block)

        def value=(v)
          assign_attributes(v)
        end

        def value
          self
        end
      end
    end

    module Schema
      def model(model_name)
        @_model = model_name.classify.constantize
      end

      def attribute(name, options = {}, &block)
        attributes.add(name, options, &block)

        define_method name do
          self.class.attributes[name].value
        end

        define_method "#{name}=" do |value|
          self.class.attributes[name].value = value
        end
      end

      def attributes
        @attributes ||= Attributes.new
      end

      def assign_attributes(hash)
        hash.each do |k, v|
          attributes[k].value = v
        end
      end
    end

    class << self
      def inherited(subclass)
        subclass.extend Schema
      end
    end
  end
end
