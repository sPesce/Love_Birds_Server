Rails.application.routes.draw do
    namespace :api do
      namespace :v1 do
        get 'find_user' => 'users#find'
        patch 'users/update' => 'users#update'
        resources :disabilities, only: [:index,:create]

        resources :users
      end
    end
end
