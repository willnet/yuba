class Yuba::ViewModel::Test < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests

  class Person
    include ActiveModel::Model
  end

  def setup
    @model = Yuba::ViewModel.new(form: Person.new)
  end
end
