Rails.application.routes.draw do

  devise_for :users
  resources :teams do
    member do
      get 'export'
    end
  end
  resources :weeks do
    member do
      post 'parse'
      post 'process_payments'
      get 'all'
      get 'aba_gst'
      get 'aba_no_gst'
      get 'prepare_aba'
      post 'generate_aba'
    end
  end

  resources :invoices do
    member do
      get 'invoice_due'
      get 'invoice_paid'
      get 'invoice_due_mail'
      get 'invoice_paid_mail'
    end
  end

  get 'users/profile' => 'users#profile', as: 'profile'
  patch 'users/profile' => 'users#profile_update', as: 'profile_update'
  resources :users do
    member do
      post 'reset'
    end
  end



  root 'dashboard#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
