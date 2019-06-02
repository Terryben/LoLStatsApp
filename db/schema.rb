# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_06_02_152948) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"

  create_table "champion_positional_stats", force: :cascade do |t|
    t.decimal "winrate"
    t.decimal "pickrate"
    t.decimal "banrate"
    t.decimal "num_of_matches_won"
    t.decimal "num_of_matches_lost"
    t.string "game_version"
    t.integer "cps_ladder_rank"
    t.integer "cps_position"
    t.bigint "champions_id"
    t.index ["champions_id"], name: "index_champion_positional_stats_on_champions_id"
  end

  create_table "champions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "title", limit: 50
  end

  create_table "matches", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "season_id"
    t.integer "queue_id"
    t.string "game_version"
    t.string "platform_id"
    t.string "game_mode"
    t.integer "map_id"
    t.string "game_type"
    t.decimal "game_duration"
    t.decimal "game_creation"
    t.integer "ladder_rank_of_match"
    t.decimal "riot_game_id"
  end

  create_table "participant_dtos", force: :cascade do |t|
    t.integer "team_id"
    t.integer "spell_2_id"
    t.integer "spell_1_id"
    t.string "highest_achieved_season_tier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "matches_id"
    t.integer "participant_id"
    t.integer "champion_id"
    t.index ["matches_id"], name: "index_participant_dtos_on_matches_id"
  end

  create_table "participant_stats_dtos", force: :cascade do |t|
    t.bigint "participant_stats_dtos_id"
    t.bigint "participant_dtos_id"
    t.boolean "first_blood_assist"
    t.decimal "vision_score"
    t.decimal "magic_damage_dealt_to_champions"
    t.decimal "damage_dealt_to_objectives"
    t.integer "total_time_crowd_control_dealt"
    t.integer "longest_time_spent_living"
    t.integer "triple_kills"
    t.integer "node_neutralize_assist"
    t.integer "player_score_9"
    t.integer "player_score_8"
    t.integer "player_score_7"
    t.integer "player_score_6"
    t.integer "player_score_5"
    t.integer "player_score_4"
    t.integer "player_score_3"
    t.integer "player_score_2"
    t.integer "player_score_1"
    t.integer "player_score_0"
    t.integer "kills"
    t.integer "total_score_rank"
    t.integer "neutral_minions_killed"
    t.decimal "damage_dealt_to_turrets"
    t.decimal "physical_damage_dealt_to_champions"
    t.integer "node_capture"
    t.integer "largest_multikill"
    t.integer "total_units_healed"
    t.integer "wards_killed"
    t.integer "largest_critical_strike"
    t.integer "largest_killing_spree"
    t.integer "quadra_kills"
    t.integer "team_objective"
    t.integer "magic_damage_dealt"
    t.integer "neutral_minions_killed_team_jungle"
    t.integer "dragon_kills"
    t.integer "perk_1_var_1"
    t.integer "perk_1_var_2"
    t.integer "perk_1_var_3"
    t.integer "perk_3_var_1"
    t.integer "perk_3_var_2"
    t.integer "perk_3_var_3"
    t.integer "perk_5_var_1"
    t.integer "perk_5_var_2"
    t.integer "perk_5_var_3"
    t.integer "perk_2_var_1"
    t.integer "perk_2_var_2"
    t.integer "perk_2_var_3"
    t.integer "perk_4_var_1"
    t.integer "perk_4_var_2"
    t.integer "perk_4_var_3"
    t.integer "item_0"
    t.integer "item_1"
    t.integer "item_2"
    t.integer "item_3"
    t.integer "item_4"
    t.integer "item_5"
    t.integer "item_6"
    t.decimal "damage_self_mitigated"
    t.decimal "magical_damage_taken"
    t.boolean "first_inhibitor_kill"
    t.decimal "true_damage_taken"
    t.integer "node_neutralize"
    t.integer "assists"
    t.integer "combat_player_score"
    t.integer "perk_primary_style"
    t.integer "gold_spent"
    t.decimal "true_damage_dealt"
    t.integer "participant_id"
    t.decimal "total_damage_taken"
    t.decimal "physical_damage_taken"
    t.integer "sight_wards_bought_in_game"
    t.decimal "total_damage_dealt_to_champions"
    t.integer "total_player_score"
    t.boolean "win"
    t.integer "objective_player_score"
    t.decimal "total_damage_dealt"
    t.integer "perk_0"
    t.integer "perk_1"
    t.integer "perk_2"
    t.integer "perk_3"
    t.integer "perk_4"
    t.integer "perk_5"
    t.integer "neutral_minions_killed_enemy_jungle"
    t.integer "deaths"
    t.integer "wards_placed"
    t.integer "perk_sub_style"
    t.integer "turret_kills"
    t.integer "gold_earned"
    t.boolean "first_blood_kill"
    t.decimal "true_damage_dealt_to_champions"
    t.integer "killing_sprees"
    t.integer "unreal_kills"
    t.integer "altars_captured"
    t.integer "champ_level"
    t.boolean "first_tower_assist"
    t.boolean "first_tower_kill"
    t.integer "double_kills"
    t.integer "node_capture_assist"
    t.integer "inhibitor_kills"
    t.boolean "first_inhibitor_assist"
    t.integer "perk_0_var_1"
    t.integer "perk_0_var_2"
    t.integer "perk_0_var_3"
    t.integer "vision_wards_bought_in_game"
    t.integer "altars_neutralized"
    t.integer "penta_kills"
    t.decimal "total_heal"
    t.integer "total_minions_killed"
    t.decimal "time_ccing_others"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "physical_damage_dealt"
    t.index ["participant_dtos_id"], name: "index_participant_stats_dtos_on_participant_dtos_id"
    t.index ["participant_stats_dtos_id"], name: "index_participant_stats_dtos_on_participant_stats_dtos_id"
  end

  create_table "participant_timeline_dtos", force: :cascade do |t|
    t.string "lane"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "creeps_pmd_0_10"
    t.decimal "creeps_pmd_10_20"
    t.decimal "creeps_pmd_20_30"
    t.decimal "creeps_pmd_30_end"
    t.decimal "xp_pmd_0_10"
    t.decimal "xp_pmd_10_20"
    t.decimal "xp_pmd_20_30"
    t.decimal "xp_pmd_30_end"
    t.decimal "gold_pmd_0_10"
    t.decimal "gold_pmd_10_20"
    t.decimal "gold_pmd_20_30"
    t.decimal "gold_pmd_30_end"
    t.decimal "damage_taken_pmd_0_10"
    t.decimal "damage_taken_pmd_10_20"
    t.decimal "damage_taken_pmd_20_30"
    t.decimal "damage_taken_pmd_30_end"
    t.decimal "damage_taken_diff_pmd_0_10"
    t.decimal "damage_taken_diff_pmd_10_20"
    t.decimal "damage_taken_diff_pmd_20_30"
    t.decimal "damage_taken_diff_pmd_30_end"
    t.integer "participant_dto_id"
    t.decimal "cs_diff_pmd_0_10"
    t.decimal "cs_diff_pmd_10_20"
    t.decimal "cs_diff_pmd_20_30"
    t.decimal "cs_diff_pmd_30_end"
    t.decimal "xp_diff_pmd_30_end"
    t.decimal "xp_diff_pmd_20_30"
    t.decimal "xp_diff_pmd_10_20"
    t.decimal "xp_diff_pmd_0_10"
  end

  create_table "player_dtos", force: :cascade do |t|
    t.string "current_platform_id"
    t.string "summoner_name"
    t.string "match_history_uri"
    t.string "platform_id"
    t.bigint "current_account_id"
    t.string "summoner_id_string"
    t.integer "participant_dto_id"
    t.integer "profile_icon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "matches_id"
    t.bigint "summoner_id"
    t.bigint "account_id"
    t.index ["matches_id"], name: "index_player_dtos_on_matches_id"
  end

  create_table "stats", force: :cascade do |t|
    t.string "name"
    t.float "percentage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "summoners", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "summoner_id"
    t.decimal "summoner_level"
    t.string "puuid"
    t.integer "profile_icon_id"
    t.string "account_id", limit: 50
  end

  create_table "team_bans_dtos", force: :cascade do |t|
    t.bigint "team_stats_dtos_id"
    t.integer "pick_turn"
    t.integer "champion_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_stats_dtos_id"], name: "index_team_bans_dtos_on_team_stats_dtos_id"
  end

  create_table "team_stats_dtos", force: :cascade do |t|
    t.boolean "first_dragon"
    t.boolean "first_inhibitor"
    t.integer "baron_kills"
    t.boolean "first_rift_herald"
    t.boolean "first_baron"
    t.integer "rift_herald_kills"
    t.boolean "first_blood"
    t.boolean "team_id"
    t.boolean "first_tower"
    t.integer "vilemaw_kills"
    t.integer "inhibitor_kills"
    t.integer "tower_kills"
    t.integer "dominion_victory_score"
    t.string "win"
    t.integer "dragon_kills"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "matches_id"
    t.index ["matches_id"], name: "index_team_stats_dtos_on_matches_id"
  end

  add_foreign_key "champion_positional_stats", "champions", column: "champions_id"
  add_foreign_key "participant_dtos", "matches", column: "matches_id"
  add_foreign_key "participant_stats_dtos", "participant_dtos", column: "participant_dtos_id"
  add_foreign_key "participant_stats_dtos", "participant_stats_dtos", column: "participant_stats_dtos_id"
  add_foreign_key "player_dtos", "matches", column: "matches_id"
  add_foreign_key "team_bans_dtos", "team_stats_dtos", column: "team_stats_dtos_id"
  add_foreign_key "team_stats_dtos", "matches", column: "matches_id"
end
