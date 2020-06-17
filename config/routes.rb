Rails.application.routes.draw do  
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  root :to => 'web/boards#show'

  scope module: :web do
    resources :developers, only: [:new, :create]
    resource :session, only: [:new, :create, :destroy]
    resource :board, only: :show
    resources :password_resets
  end

  namespace :admin do
    resources :users
  end

  namespace :api do
    namespace :v1 do
      resources :tasks, only: [:index, :show, :create, :update, :destroy]
      resources :users, only: [:index, :show]
    end
  end
end
