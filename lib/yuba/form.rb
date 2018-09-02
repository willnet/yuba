require 'yuba'
require 'yuba/form/attributes'
require 'yuba/form/coercions'
require 'yuba/form/multi_parameter_attributes'
require 'yuba/form/uniqueness_validator'
require 'active_model/naming'

module Yuba
  class Form
    include Attributes

    class << self
      def model_name
        ActiveModel::Name.new(self, nil, 'Yuba::Form')
      end

      def validates_uniqueness_of(*attr_names)
        validates_with UniquenessValidator, _merge_attributes(attr_names)
      end

      private

      def _merge_attributes(attr_names)
        options = attr_names.extract_options!.symbolize_keys
        attr_names.flatten!
        options[:attributes] = attr_names
        options
      end
    end

    def initialize(model:)
      @_model = model
    end

    def model
      @_model
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

    def push
      attributes.each do |k, v|
        if v.leaf?
          model.send("#{k}=", v.value)
        else
          # TODO: recursive assign
        end
      end
    end

    def pull
      return unless model.respond_to?(:attributes)
      model.attributes.each do |k, v|
        # TODO: association
        send("#{k}=", v) if respond_to? "#{k}="
      end
    end
  end
end
