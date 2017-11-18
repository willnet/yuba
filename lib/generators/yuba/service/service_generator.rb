module Yuba
  class ServiceGenerator < ::Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    def generate_service
      template 'service.tt', File.join('app/services', class_path, "#{file_name}_service.rb")
    end
  end
end
