require 'yuba/form/schema'
require 'yuba/form/coercions'

module Yuba
  class Form
    class AttributesDefinition < ::Hash
      attr_accessor :name, :options

      def initialize(name: 'root', options: {})
        @name = name
        @options = options
      end

      def add(name, options, &block)
        self[name] = if block
          NestedAttributesDefinitionBuilder.build(name, options, &block)
        else
          AttributeDefinition.new(name, options)
        end
      end

      def collection?
        !!@options[:collection]
      end

      def leaf?
        false
      end
    end

    class AttributeDefinition
      attr_accessor :name, :options

      def initialize(name, options)
        @name = name
        @options = options
      end

      def type
        options[:type]
      end

      def coerce(value)
        return unless value
        Coercions.coerce(type: type, value: value)
      end

      def leaf?
        true
      end
    end

    module NestedAttributesDefinitionBuilder
      def self.build(name, options, &block)
        klass = build_class(name, options, &block)
        klass.definition.name = name
        klass.definition.options = options
        klass.definition
      end

      def self.build_class(name, options, &block)
        Class.new do
          extend Schema::ClassMethods
          class_eval(&block)
        end
      end
    end
  end
end
