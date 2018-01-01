require 'yuba'
require 'yuba/form/attributes'
require 'yuba/form/coercions'
require 'yuba/form/multi_parameter_attributes'
require 'active_model/naming'

module Yuba
  class Form
    include Attributes

    class << self
      def model_name
        ActiveModel::Name.new(self, nil, 'Yuba::Form')
      end
    end

    def initialize(model:)
      @_model = model
    end

    def to_model
      @_model.to_model
    end

    def assign_attributes(attributes)
      multi_parameter_attributes = MultiParameterAttributes.call(attributes)
      multi_parameter_attributes.each do |k, v|
        public_send("#{k}=", v)
      end
    end

    def attributes=(attributes)
      assign_attributes(attributes)
    end
  end
end
