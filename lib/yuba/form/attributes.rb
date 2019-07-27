module Yuba
  class Form
    module Attributes
      extend ActiveSupport::Concern
      include ActiveModel::Validations

      class_methods do
        def definitions
          @definitions ||= ActiveSupport::HashWithIndifferentAccess.new
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

      def attributes
        @attributes ||= deep_convert({}, _attributes)
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

      def options_for(attribute_name)
        @_attributes[attribute_name].class.options
      end

      private

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

      def definitions
        self.class.definitions
      end
    end

    class Value
      delegate :leaf?, :collection?, to: self

      attr_reader :value

      def value=(v)
        @value = Coercions.coerce(type: self.class.options[:type], value: v)
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

    class Container
      delegate :leaf?, :collection?, to: self

      def value
        self
      end

      def value=(v)
        v.each do |key, value|
          _attributes[key].value = value
        end
      end

      class << self
        attr_accessor :name, :options

        def leaf?
          false
        end
      end
    end

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
  end
end
