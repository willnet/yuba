require 'test_helper'

class Yuba::ViewModel::Test < ActiveSupport::TestCase
  view_model_class = Class.new(Yuba::ViewModel) do
    property :name, public: true
    property :address, optional: true
    property :password, optional: true
  end

  test 'property works' do
    view_model = view_model_class.new(name: 'willnet', password: 'password')
    assert_equal view_model.name, 'willnet'
    assert_equal view_model.singleton_class.private_method_defined?(:password), true
  end
end
