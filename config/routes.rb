Rails.application.routes.draw do
  resources :champion_positional_stats
  get 'welcome_page/index'

  post 'matches/read_json_file'
  post 'matches/get_running_thread_count'
  post 'matches/get_matchlist_from_api'
  post 'matches/search_for_match'
  post 'matches/sort_by_game_rank'
  post 'matches/ascend_descend_next_back'
  post 'summoners/ascend_descend_next_back'
  post 'summoners/read_summoner_json'
  post 'summoners/next_index_page'
  post 'summoners/search_for_summoner'
  post 'summoners/back_index_page'
  post 'matches/next_index_page'
  post 'matches/back_index_page'
  post 'champion_positional_stats/filter_sort'
  root 'welcome_page#index'

  resources :stats
  resources :matches
  resources :participant_timeline_dto
  resources :team_stats_dto
  resources :champion
  resources :participant_stats_dto
  resources :participant_dto
  resources :player_dto
  resources :summoners
  resources :champion_positional_stats

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

