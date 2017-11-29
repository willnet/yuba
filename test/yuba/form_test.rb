require 'test_helper'

class Yuba::Form::Test < ActiveSupport::TestCase
  form_class = Class.new(Yuba::Form) do
    attribute :number, type: :int
    attribute :start_time, type: :date_time

    attribute :person do
      attribute :name

      collection :posts do
        attribute :body
      end
    end

    collection :songs do
      attribute :title
      attribute :author do
        attribute :name
        collection :emails do
          attribute :email
        end
      end
    end
  end

  model_class = Class.new do
    include ActiveModel::Model
    attr_accessor :start_time, :number
  end

  test 'create subclass' do
    Class.new(Yuba::Form)
  end

  test 'attribute works' do
    form = form_class.new(model: model_class.new)
    form.number = '1'
    assert_equal form.number, '1' # TODO: coercion
  end

  test 'nested attribute works' do
    form = form_class.new(model: model_class.new)
    form.person.name = 'willnet'
    assert_equal form.person.name, 'willnet'
  end

  test 'collection attribute works' do
    form = form_class.new(model: model_class.new)
    form.songs = [{ title: 'Burn', author: { name: 'deep purple', emails: [{email: 'deep@example.com'}] } }]
    assert_equal form.songs.first.title, 'Burn'
    assert_equal form.songs.first.author.name, 'deep purple'
    assert_equal form.songs.first.author.emails.first.email, 'deep@example.com'
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
