require 'test_helper'

class ChampionPositionalStatsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @champion_positional_stat = champion_positional_stats(:one)
  end

  test "should get index" do
    get champion_positional_stats_url
    assert_response :success
  end

  test "should get new" do
    get new_champion_positional_stat_url
    assert_response :success
  end

  test "should create champion_positional_stat" do
    assert_difference('ChampionPositionalStat.count') do
      post champion_positional_stats_url, params: { champion_positional_stat: {  } }
    end

    assert_redirected_to champion_positional_stat_url(ChampionPositionalStat.last)
  end

  test "should show champion_positional_stat" do
    get champion_positional_stat_url(@champion_positional_stat)
    assert_response :success
  end

  test "should get edit" do
    get edit_champion_positional_stat_url(@champion_positional_stat)
    assert_response :success
  end

  test "should update champion_positional_stat" do
    patch champion_positional_stat_url(@champion_positional_stat), params: { champion_positional_stat: {  } }
    assert_redirected_to champion_positional_stat_url(@champion_positional_stat)
  end

  test "should destroy champion_positional_stat" do
    assert_difference('ChampionPositionalStat.count', -1) do
      delete champion_positional_stat_url(@champion_positional_stat)
    end

    assert_redirected_to champion_positional_stats_url
  end
end
