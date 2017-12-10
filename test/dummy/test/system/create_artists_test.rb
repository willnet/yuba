require "application_system_test_case"

class CreateArtistsTest < ApplicationSystemTestCase
  test 'visiting #index not using view_model option to render' do
    visit artists_url

    assert_selector 'h2', text: 'Artists Index'
  end

  test 'visiting #new using view_model option to render' do
    visit new_artist_url

    assert_selector 'h2', text: 'New Artist'
  end
end
