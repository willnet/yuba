module Yuba
  class Form
    module Schema
      module ClassMethods
        def self.extended(base)
          base.include ActiveModel::Validations

          base.send(:define_method, :valid?) do |context = nil|
            super(context)
            self.class.definition.each do |key, sub_definition|
              next if sub_definition.leaf?
              sub_definition.valid?(context)
              errors[key] << sub_definition.errors unless sub_definition.errors.empty?
            end
            errors.empty?
          end
        end

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
          if definition.leaf?
            local_attr[k] = definition.coerce(v)
          elsif definition.collection?
            local_attr[k] = CollectionAttributes.new(definition)
            v.each_with_index do |h, i|
              local_attr[k][i] = Attributes.new(definition)
              assign_attributes(h, local_attr[k][i], definition)
            end
          else
            local_attr[k] = Attributes.new(definition)
            assign_attributes(v, local_attr[k], definition)
          end
        end
      end
    end
  end
end
