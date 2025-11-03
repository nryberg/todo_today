Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: 'users/registrations'
  }

  root "tasks#index"

  resources :tasks do
    member do
      post :complete
      delete :uncomplete
    end
    collection do
      delete :reset_all
    end
  end

  resources :reports, only: [:index]
end
