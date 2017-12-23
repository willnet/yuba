require 'yuba'
require 'yuba/form/attributes'
require 'yuba/form/coercions'
require 'active_model/naming'

module Yuba
  class Form
    class << self
      def model_name
        ActiveModel::Name.new(self, nil, 'Yuba::Form')
      end
    end

    def initialize(model:)
      @_model = model
    end

    include Attributes
  end
end
