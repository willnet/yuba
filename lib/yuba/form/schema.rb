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
  end
end
