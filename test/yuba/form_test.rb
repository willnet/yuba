class Yuba::Form::Test < ActiveSupport::TestCase
  test 'create subclass' do
    Class.new(Yuba::Form)
  end

  test 'property works' do
    klass = Class.new(Yuba::Form) do
      property :number, type: :int
    end

    model_class = Class.new do
      include ActiveModel::Model

      attr_accessor :number
    end

    object = klass.new(model_class.new)
    object.number = '1'
    assert_equal object.number, 1
  end
end
