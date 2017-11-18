module Yuba
  class ViewModelGenerator < ::Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    def generate_view_model
      template 'view_model.tt', File.join('app/view_models', class_path, "#{file_name}_view_model.rb")
    end
  end
end
