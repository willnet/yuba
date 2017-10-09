require "disposable/twin/coercion"

module Yuba
  class Form < ::Reform::Form
    module Types
      include Dry::Types.module
    end

    Coercion = Disposable::Twin::Coercion

    class << self
      def inherited(subclass)
        subclass.feature Coercion
      end

      def property(name, **options)
        super unless options[:type]
        klass = options[:type].to_s.classify
        options[:type] = "Yuba::Form::Types::#{klass}".constantize
        super(name, **options)
      end
    end
  end
end
