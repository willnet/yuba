require 'test_helper'

class Yuba::Form::Test < ActiveSupport::TestCase
  simple_form_class = Class.new(Yuba::Form) do
    attribute :number, type: :int
    attribute :start_time, type: :date_time

    validates :number, numericality: { less_than: 100 }

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

  collection_form_class = Class.new(Yuba::Form) do
    collection :songs do
      attribute :title
      attribute :author do
        attribute :name
        collection :emails do
          attribute :email
        end
      end
    end

    def self.model_name
      ActiveModel::Name.new(self, nil, 'Test')
    end
  end

  model_class = Class.new do
    include ActiveModel::Model
    attr_accessor :start_time, :number

    def self.model_name
      ActiveModel::Name.new(self, nil, 'Test')
    end
  end

  test 'create subclass' do
    Class.new(Yuba::Form)
  end

  test 'attribute works' do
    form1 = simple_form_class.new(model: model_class.new)
    form1.number = '1'
    assert_equal 1, form1.number

    form2 = simple_form_class.new(model: model_class.new)
    form2.number = '2'
    assert_equal 2, form2.number
    assert_equal 1, form1.number
  end

  test 'nested attribute works' do
    form = nested_form_class.new(model: model_class.new)
    form.person.name = 'willnet'
    assert_equal form.person.name, 'willnet'
  end

  test 'collection attribute works' do
    form = collection_form_class.new(model: model_class.new)
    form.songs = [{ title: 'Burn', author: { name: 'deep purple', emails: [{email: 'deep@example.com'}] } }]
    assert_equal form.songs.first.title, 'Burn'
    assert_equal form.songs.first.author.name, 'deep purple'
    assert_equal form.songs.first.author.emails.first.email, 'deep@example.com'
  end

  test 'validation works' do
    form = simple_form_class.new(model: model_class.new)
    form.number = 10
    assert form.valid?
    form.number = 100
    assert form.invalid?
  end

  test 'nested validation works' do
    form = nested_form_class.new(model: model_class.new)
    assert form.invalid?
    form.person.name = 'willnet'
    assert form.valid?
  end

=begin
  test "munges multi-param date and time fields into a valid Time attribute" do
    start_time_params = { "start_time(1i)"=>"2000", "start_time(2i)"=>"1", "start_time(3i)"=>"1", "start_time(4i)"=>"12", "start_time(5i)"=>"00" }
    form = form_class.new(model: model_class.new)
    form.validate(start_time_params)
    assert_equal form.start_time, Time.zone.local(2000, 1, 1, 12, 0)
  end

  test "munges multi-param date and date fields into a valid Date attribute" do
    start_time_params = { "start_time(1i)"=>"2000", "start_time(2i)"=>"1", "start_time(3i)"=>"1" }
    form = form_class.new(model: model_class.new)
    form.validate(start_time_params)
    assert_equal form.start_time, Time.zone.local(2000, 1, 1).to_date
  end
=end
end
