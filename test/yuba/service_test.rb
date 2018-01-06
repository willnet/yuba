require 'test_helper'

class Yuba::Service::Test < ActiveSupport::TestCase
  service_class = Class.new(Yuba::Service) do
    property :name, public: true
    property :address, optional: true
    property :password, optional: true

    def call
    end
  end

  test 'property works' do
    service = service_class.new(name: 'willnet', password: 'password')
    assert_equal service.name, 'willnet'
    assert_equal service.singleton_class.private_method_defined?(:password), true
  end

  test 'raise argument error on assinging key exclude property' do
    assert_raises(ArgumentError) { service_class.new(name: 'willnet', age: 37) }
  end

  test '.call return self' do
    assert service_class.call.is_a? Yuba::Service
  end

  test '#success? return true by default' do
    service = service_class.new
    assert_equal service.success?, true
  end

  test '#success? return false after call #fail!' do
    service = service_class.new
    service.fail!
    assert_equal service.success?, false
  end

  test '#failure? return false by default' do
    service = service_class.new
    assert_equal service.failure?, false
  end

  test '#failure? return true after call #fail!' do
    service = service_class.new
    service.fail!
    assert_equal service.failure?, true
  end
end
