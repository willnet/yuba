require 'yuba/form/schema'
require 'yuba/form/definition'
require 'yuba/form/attributes'

module Yuba
  class Form
    def initialize(model:)
    end

    class << self
      def inherited(subclass)
        subclass.extend Schema::ClassMethods
        subclass.include Schema
      end
    end
  end
end
