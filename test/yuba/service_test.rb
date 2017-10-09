class Yuba::Service::Test < ActiveSupport::TestCase
  service_class = Class.new(Yuba::Service) do
    property :name
    property :address, optional: true
  end

  test 'property works' do
    service = service_class.new(name: 'willnet')
    assert_equal service.name, 'willnet'
  end

  test 'raise argument error on assinging key exclude property' do
    assert_raises(ArgumentError) { service_class.new(name: 'willnet', age: 37) }
  end
end
