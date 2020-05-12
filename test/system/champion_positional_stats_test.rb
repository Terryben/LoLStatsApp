require "application_system_test_case"

class ChampionPositionalStatsTest < ApplicationSystemTestCase
  setup do
    @champion_positional_stat = champion_positional_stats(:one)
  end

  test "visiting the index" do
    visit champion_positional_stats_url
    assert_selector "h1", text: "Champion Positional Stats"
  end

  test "creating a Champion positional stat" do
    visit champion_positional_stats_url
    click_on "New Champion Positional Stat"

    click_on "Create Champion positional stat"

    assert_text "Champion positional stat was successfully created"
    click_on "Back"
  end

  test "updating a Champion positional stat" do
    visit champion_positional_stats_url
    click_on "Edit", match: :first

    click_on "Update Champion positional stat"

    assert_text "Champion positional stat was successfully updated"
    click_on "Back"
  end

  test "destroying a Champion positional stat" do
    visit champion_positional_stats_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Champion positional stat was successfully destroyed"
  end
end
