require 'delegate'

module Yuba
  class Form
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
  end
end
