class Yuba::ViewModel::Test < ActiveSupport::TestCase
  view_model_class = Class.new(Yuba::Service) do
    property :name
    property :address, optional: true
  end

  test 'property works' do
    view_model = view_model_class.new(name: 'willnet')
    assert_equal view_model.name, 'willnet'
  end
end
