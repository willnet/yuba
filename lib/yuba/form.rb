require 'yuba/form/coercion'

module Yuba
  class Form < ::Reform::Form
    class << self
      def inherited(subclass)
        subclass.feature Coercion
      end
    end
  end
end
