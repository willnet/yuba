require 'dry-types'

module Yuba
  class Form
    module Coercion
      module Types
        # include Dry::Types.module
      end

      module ClassMethods
        def property(name, options={}, &block)
          super(name, options, &block).tap do
            break unless options[:type]
            coercing_setter!(name, options[:type])
          end
        end

        def coercing_setter!(name, type)
          class_name = type.to_s.classify
          type_class = "Yuba::Form::Coercion::Types::Form::#{class_name}".constantize

          mod = Module.new do
            define_method("#{name}=") do |value|
              super type_class.(value)
            end
          end
          include mod
        end
      end

      def self.included(includer)
        includer.extend ClassMethods
      end
    end
  end
end
