require 'test_helper'

class Yuba::Service::Test < ActiveSupport::TestCase
  service_class = Class.new(Yuba::Service) do
    property :name, public: true
    property :address, optional: true
    property :password, optional: true

    def call
    end
  end

  blank_service_class = Class.new(Yuba::Service) do
    def call
    end
  end

  # For checking https://github.com/willnet/yuba/issues/9
  Class.new(Yuba::Service) do
    property :name
  end

  test 'property works' do
    service = service_class.new(name: 'willnet', password: 'password')
    assert_equal service.name, 'willnet'
    assert_equal service.singleton_class.private_method_defined?(:password), true
  end

  test 'raise argument error on initialize with properties not declared' do
    assert_raises(ArgumentError) { service_class.new(name: 'willnet', age: 37) }
  end

  test 'raise argument error on initialize without needed properties' do
    assert_raises(ArgumentError) { service_class.new }
  end

  test '.call return self' do
    assert blank_service_class.call.is_a? Yuba::Service
  end

  test '#success? return true by default' do
    service = blank_service_class.new
    assert_equal service.success?, true
  end

  test '#success? return false after call #fail!' do
    service = blank_service_class.new
    service.fail!
    assert_equal service.success?, false
  end

  test '#failure? return false by default' do
    service = blank_service_class.new
    assert_equal service.failure?, false
  end

  test '#failure? return true after call #fail!' do
    service = blank_service_class.new
    service.fail!
    assert_equal service.failure?, true
  end
end
