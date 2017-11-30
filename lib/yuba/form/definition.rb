require 'yuba/form/schema'
require 'yuba/form/coercions'

module Yuba
  class Form
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
        klass
      end

      def self.build_class(name, options, &block)
        Class.new do
          extend Schema::ClassMethods # validates が定義されている
          class_eval(&block)

          class << self
            attr_accessor :name, :options

            delegate_missing_to :definition

            def definitions
              @definitions = {}
            end

            def add(name, options, &block)
              definitions[name] = if block
                NestedAttributesDefinitionBuilder.build(name, options, &block)
              else
                AttributeDefinition.new(name, options)
              end
            end

            def collection?
              !!options[:collection]
            end

            def leaf?
              false
            end
          end

          delegate_missing_to :@attributes

          def definition
            self.class.definition
          end

          def attributes
            @attributes ||= if definition.collection?
              []
            else
              {}
            end
          end

          def initialize
            definition.each do |key, sub_definition|
              define_singleton_method(key) do
                if sub_definition.leaf?
                  attributes[key]
                else
                  attributes[key] ||= sub_definition.new
                end
              end

              define_singleton_method("#{key}=") do |value|
                attributes[key] = value
              end
            end
          end
        end
      end
    end
  end
end
