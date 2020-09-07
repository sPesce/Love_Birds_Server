Rails.application.routes.draw do
    namespace :api do
      namespace :v1 do
        get 'find_user' => 'users#find'
        patch 'users/update' => 'users#update'
        post 'find_matches' => 'users#get_closest_matches'
        resources :disabilities, only: [:index,:create]
        resources :interests, only: [:create]

        resources :users
      end
    end
end
