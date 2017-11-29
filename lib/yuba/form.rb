require 'delegate'

module Yuba
  class Form
    def initialize(model:)
    end

    class Attributes < ::Hash
      def add(name, options, &block)
        self[name] = if block
          if options[:collection]
            CollectionAttributes.new(name, options, &block)
          else
            NestedAttributeBuilder.build(name, options, &block)
          end
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

    class CollectionAttributes < SimpleDelegator
      attr_accessor :name, :options, :block

      def initialize(name, options, &block)
        @name = name
        @options = options
        @block = block
        @collection = []
        super(@collection)
      end

      def build_nested_attribute
        NestedAttributeBuilder.build(name, options, &block)
      end

      def value=(array)
        @collection = array.map do |hash|
          nested_attribute = build_nested_attribute
          nested_attribute.value = hash
          nested_attribute
        end
        __setobj__(@collection)
        @collection
      end

      def value
        self
      end
    end

    module NestedAttributeBuilder
      def self.build(name, options, &block)
        klass = build_class(name, options, &block)
        klass.new
      end

      def self.build_class(name, options, &block)
        Class.new do
          extend Schema::ClassMethods
          include Schema
          class_eval(&block)

          def value=(v)
            assign_attributes(v)
          end

          def value
            self
          end
        end
      end
    end

    module Schema
      module ClassMethods
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

        def collection(name, options = {}, &block)
          options[:collection] = true
          attribute(name, options, &block)
        end

        def attributes
          @attributes ||= Attributes.new
        end
      end

      def assign_attributes(hash)
        hash.each do |k, v|
          self.class.attributes[k].value = v
        end
      end
    end

    class << self
      def inherited(subclass)
        subclass.extend Schema::ClassMethods
        subclass.include Schema
      end
    end
  end
end
