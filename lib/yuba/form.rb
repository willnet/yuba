require 'yuba/form/coercion'
require 'yuba/form/multi_parameter_attributes'

module Yuba
  class Form < ::Reform::Form
    class << self
      def inherited(subclass)
        subclass.feature Coercion
        subclass.feature MultiParameterAttributes
        subclass.include Reform::Form::ActiveModel::ModelReflections
      end
    end
  end
end
