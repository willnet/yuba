require 'test_helper'

class Yuba::ViewModel::Rendering::Test < ActiveSupport::TestCase
  dummy_rendering_module = Module.new do
    def render(*args); end
    def view_assigns
      {}
    end

    private

    def _protected_ivars
      {}
    end
  end

  action_controller_class = Class.new do
    include dummy_rendering_module
    include Yuba::ViewModel::Rendering
  end

  simple_view_model_class = Class.new(Yuba::ViewModel) do
    property :name, public: true
  end

  view_model_class_with_predicate_method = Class.new(Yuba::ViewModel) do
    property :name, public: true

    def enable?
      true
    end
  end

  test 'it works' do
    action_controller = action_controller_class.new
    view_model = simple_view_model_class.new(name: 'willnet')
    action_controller.render(view_model: view_model)
    assert_equal({ name: 'willnet' }, action_controller.view_assigns)
  end

  test 'filter method names to use as instance variable' do
    action_controller = action_controller_class.new
    view_model = view_model_class_with_predicate_method.new(name: 'willnet')
    action_controller.render(view_model: view_model)
    assert_equal({ name: 'willnet' }, action_controller.view_assigns)
  end
end
