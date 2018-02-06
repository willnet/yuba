require 'test_helper'

class Yuba::Form::SyncTest < ActiveSupport::TestCase
  simple_form_class = Class.new(Yuba::Form) do
    attribute :name

    def self.model_name
      ActiveModel::Name.new(self, nil, 'Simple')
    end
  end

  model_class = Class.new do
    include ActiveModel::Model
    attr_accessor :name

    def self.model_name
      ActiveModel::Name.new(self, nil, 'Test')
    end

    def attributes
      { name: name }
    end
  end

  test '#push works' do
    model = model_class.new
    form = simple_form_class.new(model: model)
    form.attributes = { name: 'willnet' }
    form.push
    assert_equal 'willnet', model.name
  end

  test '#pull works' do
    model = model_class.new(name: 'willnet')
    form = simple_form_class.new(model: model)
    form.pull
    assert_equal({ name: 'willnet'}, form.attributes)
  end
end
