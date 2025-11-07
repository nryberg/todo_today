Rails.application.routes.draw do
  # Conditionally configure devise routes based on Google OAuth feature flag
  if ENV['ENABLE_GOOGLE_OAUTH']&.downcase == 'true'
    devise_for :users, controllers: {
      omniauth_callbacks: 'users/omniauth_callbacks',
      registrations: 'users/registrations'
    }
  else
    devise_for :users, controllers: {
      registrations: 'users/registrations'
    }
  end

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
