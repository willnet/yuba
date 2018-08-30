require 'test_helper'

class Yuba::Form::Coercions::Test < ActiveSupport::TestCase
  form_class = Class.new(Yuba::Form) do
    attribute :default
    attribute :integer, type: :int
    attribute :string, type: :string
    attribute :date, type: :date
    attribute :datetime, type: :datetime
    attribute :boolean, type: :boolean
    attribute :float, type: :float
    attribute :decimal, type: :decimal
    attribute :array, type: :array
    attribute :hash, type: :hash
  end

  model_class = Class.new do
    include ActiveModel::Model
  end

  test 'it works' do
    form = form_class.new(model: model_class.new)
    form.integer = '1'
    assert_equal 1, form.integer
    form.string = 1
    assert_equal '1', form.string
    form.date = '2017/12/31'
    assert_equal Date.new(2017, 12, 31), form.date
    form.datetime = '2017/12/31 12:34:56'
    assert_equal Time.zone.local(2017, 12, 31, 12, 34, 56), form.datetime
    [false, 0, '0', 'f', 'F', 'false', 'FALSE', 'off', 'OFF'].each do |falsy|
      form.boolean = falsy
      refute form.boolean
    end
    [1, '1', 't', 'hoge'].each do |truthy|
      form.boolean = truthy
      assert form.boolean
    end
    form.float = '3.5'
    assert 3.5, form.float
    form.decimal = '123'
    assert BigDecimal(123), form
    form.array = ''
    assert Array.new, form.array
    form.hash = ''
    assert Hash.new, form.hash
  end
end
