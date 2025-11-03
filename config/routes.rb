Rails.application.routes.draw do
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
