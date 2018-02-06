require 'test_helper'

class Yuba::Form::ValidationTest < ActiveSupport::TestCase
  simple_form_class = Class.new(Yuba::Form) do
    attribute :number, type: :int
    attribute :name

    validates :number, numericality: { less_than: 100 }
    validates :name, uniqueness: true

    def self.model_name
      ActiveModel::Name.new(self, nil, 'Simple')
    end
  end

  nested_form_class = Class.new(Yuba::Form) do
    attribute :person do
      attribute :name
      validates :name, presence: true

      collection :posts do
        attribute :body
      end
    end

    def self.model_name
      ActiveModel::Name.new(self, nil, 'Simple')
    end
  end

  model_class = Class.new do
    include ActiveModel::Model

    def self.model_name
      ActiveModel::Name.new(self, nil, 'Test')
    end
  end

  test 'simple validation works' do
    form = simple_form_class.new(model: User.new)
    form.number = 10
    assert form.valid?
    form.number = 100
    assert form.invalid?
  end

  test 'uniqueness validation works' do
    form = simple_form_class.new(model: User.new)
    form.name = 'willnet'
    form.number = 10
    assert form.valid?
    User.create!(name: 'willnet')
    assert form.invalid?
  end

  test 'nested validation works' do
    form = nested_form_class.new(model: model_class.new)
    assert form.invalid?
    form.person.name = 'willnet'
    assert form.valid?
  end
end
