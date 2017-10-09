require 'yuba/form/coercion'
require 'yuba/form/multi_parameter_attributes'

module Yuba
  class Form < ::Reform::Form
    class << self
      def inherited(subclass)
        subclass.feature Coercion
        subclass.feature MultiParameterAttributes
      end
    end
  end
end
