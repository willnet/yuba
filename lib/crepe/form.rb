module Crepe
  class Form
    include ActiveModel::Model
    class_attribute :_model_attribute

    class << self
      # TODO: reformのようにネストできるようにしたい
      def attribute(name)
        attr_accessor name
      end

      def collection(name)
      end

      def model(name)
        self._model_attribute = name
      end

      def build(**args)
        new(**args)
      end
    end

    def save
      valid? && persist
    end

    def persist
    end

    def model
      send(_model_attribute)
    end

    def model_name
      model&.model_name
    end
  end
end
