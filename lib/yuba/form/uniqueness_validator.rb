module Yuba
  class Form
    class UniquenessValidator < ActiveModel::EachValidator
      def validate_each(form, attribute, value)
        model = form.model # TODO: multiple models
        original_attribute = form.options_for(attribute).fetch(:private_name, attribute)
        query = if options[:case_sensitive] == false && value
                 model.class.where("lower(#{original_attribute}) = ?", value.downcase)
               else
                 model.class.where(original_attribute => value)
               end
        if model.persisted?
         query = query.where("#{model.class.primary_key} != ?", model.id)
        end
        Array(options[:scope]).each do |field|
         query = query.where(field => form.send(field))
        end
        form.errors.add(attribute, :taken) if query.count > 0
      end
    end
  end
end
