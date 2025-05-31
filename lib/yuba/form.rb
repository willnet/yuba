require 'yuba/form/coercion'
require 'yuba/form/multi_parameter_attributes'
require 'reform/form/active_model/validations'

module Yuba
  class Form < ::Reform::Form
    class << self
      def inherited(subclass)
        subclass.feature Coercion
        subclass.feature MultiParameterAttributes
        subclass.include Reform::Form::ActiveRecord
        subclass.include Reform::Form::ActiveModel::ModelReflections
        subclass.include Reform::Form::ActiveModel::Validations
      end
    end
  end
end
