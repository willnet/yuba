require "application_system_test_case"

class CreateArtistsTest < ApplicationSystemTestCase
  test "visiting the new" do
    visit new_artist_url

    assert_selector 'h2', text: 'New Artist'
  end
end
