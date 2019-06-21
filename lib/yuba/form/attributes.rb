require 'delegate'

module Yuba
  class Form
    class CollectionAttributesContainer
      include Enumerable

      attr_accessor :items

      def initialize(definition)
        self.items = []
        @definition = definition
      end

      def [](*args)
        item = items[*args]
        return item if item
        items[args.first] = @definition.new
      end

      def value
        self
      end

      def each(&block)
        items.each(&block)
      end

      def value=(v)
        v.each_with_index do |hash, i|
          self[i].value = hash
        end
      end

      def valid?(context = nil)
        items.each do |item|
          item.valid?
          errors << item.errors unless item.errors.empty?
        end
        errors.empty?
      end

      def leaf?
        false
      end

      def errors
        @errors ||= []
      end
    end

    module Attributes
      extend ActiveSupport::Concern
      include ActiveModel::Validations

      def attributes
        @attributes ||= deep_convert({}, _attributes)
      end

      def deep_convert(result, attrs)
        attrs.each do |k, v|
          if v.leaf?
            result[k] = v.value
          elsif v.collection?
            result[k] = []
            deep_convert_array(result[k], v)
          else
            result[k] = {}
            deep_convert(result[k], v)
          end
        end
        result
      end

      def deep_covert_array(result, attrs)
        attrs.each do |v|
          result << deep_convert(result, v)
        end
        result
      end

      def _attributes
        return @_attributes if instance_variable_defined?(:@_attributes)
        @_attributes = ActiveSupport::HashWithIndifferentAccess.new
        definitions.each do |key, sub_definition|
          if sub_definition.collection?
            @_attributes[key] = CollectionAttributesContainer.new(sub_definition)
          else
            @_attributes[key] = sub_definition.new
          end
        end
        @_attributes
      end

      def value
        self
      end

      def value=(v)
        if leaf?
          _attributes.value = v
        else
          v.each do |key, value|
            _attributes[key].value = value
          end
        end
      end

      def leaf?
        self.class.leaf?
      end

      def definitions
        self.class.definitions
      end

      def options_for(attribute_name)
        @_attributes[attribute_name].class.options
      end

      def valid?(context = nil)
        super(context)
        _attributes.each do |key, sub_attributes|
          next if sub_attributes.leaf?
          sub_attributes.valid?(context)
          errors[key] << sub_attributes.errors unless sub_attributes.errors.empty?
        end
        errors.empty?
      end

      class_methods do
        attr_accessor :name, :options

        def definitions
          @definitions ||= ActiveSupport::HashWithIndifferentAccess.new
        end

        def leaf?
          false
        end

        def collection?
          !!options[:collection]
        end

        def collection(name, options = {}, &block)
          options[:collection] = true
          attribute(name, options, &block)
        end

        def attribute(name, options = {}, &block)
          if block
            container = build_container_class(name, options)
            container.class_eval(&block)
            definitions[name] = container
          else
            leaf = build_leaf_class(name, options)
            definitions[name] = leaf
          end

          define_method name do
            # leafならleafの値、nodeならnode自身
            _attributes[name].value
          end

          define_method "#{name}=" do |value|
            # なかったらraise
            _attributes[name].value = value
          end
        end

        def build_container_class(name, options)
          klass = Class.new(Container) do
            include Attributes
          end
          klass.name = name.to_s
          klass.options = options
          klass
        end

        def build_leaf_class(name, options)
          klass = Class.new(Value)
          klass.name = name.to_s
          klass.options = options
          klass
        end
      end
    end

    class Value
      attr_reader :value

      def value=(v)
        @value = Coercions.coerce(type: self.class.options[:type], value: v)
      end

      def leaf?
        true
      end

      class << self
        attr_accessor :name, :options

        def leaf?
          true
        end

        def collection?
          false
        end
      end
    end

    class Container; end
  end
end
