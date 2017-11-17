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

  test '#success? return true by default' do
    service = service_class.new
    assert_equal service.success?, true
  end

  test '#success? return false after call #failure' do
    service = service_class.new
    service.failure
    assert_equal service.success?, false
  end

  test '#failure? return false by default' do
    service = service_class.new
    assert_equal service.failure?, false
  end

  test '#failure? return true after call #failure' do
    service = service_class.new
    service.failure
    assert_equal service.failure?, true
  end
end
