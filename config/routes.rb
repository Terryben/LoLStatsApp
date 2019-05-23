Rails.application.routes.draw do
  get 'welcome_page/index'

  resources :stats
  resources :matches
  post 'matches/read_json_file'
  root 'welcome_page#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
