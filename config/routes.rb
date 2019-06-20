Rails.application.routes.draw do
  get 'welcome_page/index'

  resources :stats
  resources :matches
  resources :participant_timeline_dto
  resources :team_stats_dto
  resources :champion
  resources :participant_stats_dto
  resources :participant_dto
  resources :player_dto
  post 'matches/read_json_file'
  root 'welcome_page#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end