require 'yuba'
require 'yuba/form/coercions'

module Yuba
  class Form
    def initialize(model:)
    end
    # Hashでの入れ子とArrayでの入れ子で挙動が少し違うのをどう解決するか
    # 同一の性質を持たないと入れ子にできないので、場合分けするしかないかな

    class CollectionAttributeContainer < Array
      def initialize(definition, *args)
        @definition = definition
        super(*args)
      end

      def [](*args)
        item = super
        return item if item
        self[args.first] = @definition.new
      end
    end

    module ContainerBehavior
      extend ActiveSupport::Concern

      def attributes
        return @attributes if @attributes
        @attributes = {}
        definitions.each do |key, sub_definition|
          if sub_definition.collection?
            @attributes[key] = CollectionAttributeContainer.new(sub_definition)
          else
            @attributes[key] = sub_definition.new
          end
        end
        @attributes
      end

      def value
        self
      end

      def value=(v)
        if definition.collection?
          v.each_with_index do |hash, i|
            attributes[i][key].value = value
          end
        elsif !definition.leaf?
          v.each do |key, value|
            attributes[key].value = value
          end
        else
          attributes[key].value = v
        end
        # 自身がcollectionなのかhashなのかで挙動が変わる
        # collectionなら各attributesに再帰的にassign
      end

      def definitions
        self.class.definitions
      end

      included do
        include ActiveModel::Validations
      end

      class_methods do
        attr_accessor :name, :options

        def definitions
          @definitions ||= {}
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

        def attribute(name, optiions = {}, &block)
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
            attributes[name].value
          end

          define_method "#{name}=" do |value|
            # なかったらraise
            attributes[name].value = value
          end
        end

        def build_container_class(name, options)
          klass = Class.new do
            include ContainerBehavior
          end
          klass.name = name
          klass.options = options
          klass
        end

        def build_leaf_class(name, options)
          klass = Class.new do
            attr_reader :value

            def value=(v)
              # options が nil なのでちゃんとoptionsが渡ってない
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

          klass.name = name
          klass.options = options
          klass
        end
      end
    end
    include ContainerBehavior
  end
end
