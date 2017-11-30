require 'yuba'
require 'yuba/form/schema'
require 'yuba/form/definition'
require 'yuba/form/attributes'
require 'active_model/naming'

module Yuba
  class Form
    class << self
      delegate :human_attribute_name, :lookup_ancestors, to: :@_model

      def model_name
        ActiveModel::Name.new(self, nil, 'Yuba::Form')
      end
    end

    def initialize(model:)
      @_model = model
    end

    class << self
      def inherited(subclass)
        subclass.extend Schema::ClassMethods
        subclass.include Schema
        #subclass.include ActiveModel::Validations
        subclass.extend ActiveModel::Naming # ここでサブクラスにmodel_nameが定義されるので、スーパークラスに定義しても無駄
      end
    end
  end
end
