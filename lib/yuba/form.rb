require 'delegate'

module Yuba
  class Form

    module Schema
      module ClassMethods
        def model(model_name)
          @_model = model_name.classify.constantize
        end

        def attribute(name, options = {}, &block)
          definition.add(name, options, &block)

          define_method name do
            attributes[name]
          end

          define_method "#{name}=" do |value|
            assign_attributes({name.to_sym =>  value})
          end
        end

        def collection(name, options = {}, &block)
          options[:collection] = true
          attribute(name, options, &block)
        end

        def definition
          @definition ||= AttributesDefinition.new
        end
      end

      def attributes
        @attributes ||= Attributes.new(self.class.definition)
      end

      def [](name)
        send(name)
      end

      def assign_attributes(hash, local_attr = attributes, local_def = self.class.definition)
        hash.each do |k, v|
          definition = local_def[k]
          next unless definition
          if v.is_a? Hash # TODO: 値ではなく定義を見る
            local_attr[k] = Attributes.new(definition)
            assign_attributes(v, local_attr[k], definition)
          elsif v.is_a? Array
            local_attr[k] = CollectionAttributes.new(definition)
            v.each_with_index do |h, i|
              local_attr[k][i] = Attributes.new(definition)
              assign_attributes(h, local_attr[k][i], definition)
            end
          else
            local_attr[k] = definition.coerce(v)
          end
        end
      end
    end

    def initialize(model:)
    end

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

      def coerce(value)
        value
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

    class Attributes < SimpleDelegator
      def initialize(definition)
        @definition = definition
        @attributes = {}
        @definition.each do |key, sub_definition|
          define_singleton_method(key) do
            if sub_definition.leaf?
              @attributes[key]
            elsif sub_definition.collection?
              @attributes[key] ||= CollectionAttributes.new(sub_definition)
            else
              @attributes[key] ||= Attributes.new(sub_definition)
            end
          end

          define_singleton_method("#{key}=") do |value|
            @attributes[key] = value
          end
        end
        super(@attributes)
      end

      def [](key)
        if @definition.collection?
          super(key)
        else
          send(key)
        end
      end
    end

    class CollectionAttributes < SimpleDelegator
      def initialize(definition)
        @definition = definition
        @collection = []
        super(@collection)
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
