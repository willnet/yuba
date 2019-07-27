module Yuba
  class Form
    module Attributes
      extend ActiveSupport::Concern
      include ActiveModel::Validations

      class_methods do
        def definitions
          @definitions ||= ActiveSupport::HashWithIndifferentAccess.new
        end

        def collection(name, options = {}, &block)
          options[:collection] = true
          attribute(name, options, &block)
        end

        def attribute(name, options = {}, &block)
          klass = if block
                    build_container_class(name, options, &block)
                  else
                    build_leaf_class(name, options)
                  end
          definitions[name] = klass

          define_method name do
            # leafならleafの値、nodeならnode自身
            _attributes[name].value
          end

          define_method "#{name}=" do |value|
            # なかったらraise
            _attributes[name].value = value
          end
        end

        private

        def build_container_class(name, options, &block)
          klass = Class.new(Container) do
            include Attributes
          end
          klass.name = name.to_s
          klass.options = options
          klass.class_eval(&block)
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
        _attributes.each do |key, attr|
          next if attr.leaf?
          attr.valid?(context)
          errors[key] << attr.errors unless attr.errors.empty?
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
        definitions.each do |key, definition|
          @_attributes[key] = definition.build
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
        alias_method :build, :new

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

        def build
          collection? ? ContainerCollection.new(self) : new
        end

        def leaf?
          false
        end

        def collection?
          options[:collection]
        end
      end
    end

    class ContainerCollection
      include Enumerable

      attr_accessor :items

      delegate :each, to: :items

      def initialize(definition)
        @items = []
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

      def leaf?
        false
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

      def errors
        @errors ||= []
      end
    end
  end
end
