Rails.application.routes.draw do

  namespace :api do
    resources :users, only: [:create, :show, :update, :delete]
    resources :courses, only: [:create, :index, :show] do
        post ":subscribe", to: "courses#subscribe"
    end
    resources :participants, only: [:create, :show, :update, :delete]
    resources :reg, only: [:create]
    resources :session, only: [:create, :destroy]
    delete ":session", to: "session#destroy"
  end

end
