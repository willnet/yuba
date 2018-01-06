require 'reform/rails'
require 'dry/types'

module Yuba
  autoload :Form, 'yuba/form'
  autoload :Service, 'yuba/service'
  autoload :ViewModel, 'yuba/view_model'
end

ActiveSupport.on_load(:action_controller) do
  ActionController::Base.include(Yuba::ViewModel::Rendering)
end
