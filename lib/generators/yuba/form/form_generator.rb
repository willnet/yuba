module Yuba
  class FormGenerator < ::Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    def generate_form
      template 'form.tt', File.join('app/forms', class_path, "#{file_name}_form.rb")
    end
  end
end
