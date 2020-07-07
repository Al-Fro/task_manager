Rails.application.routes.draw do  
  root :to => 'web/boards#show'

  scope module: :web do
    resources :developers, only: [:new, :create]
    resource :session, only: [:new, :create, :destroy]
    resource :board, only: :show
  end

  namespace :admin do
    resources :users
  end

  namespace :api do
    namespace :v1 do
      resources :tasks, only: [:index, :show, :create, :update, :destroy] do
        member do
          put 'attach_image'
          put 'remove_image'
        end
      end
      resources :users, only: [:index, :show]
    end
  end
end
