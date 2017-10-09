class Yuba::Form::Test < ActiveSupport::TestCase
  test 'create subclass' do
    Class.new(Yuba::Form)
  end

  test 'property works' do
    Class.new(Yuba::Form) do
      property :name, type: :int
    end
  end
end
