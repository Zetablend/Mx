Rails.application.routes.draw do
  get "otp_sessions/new"
  get "otp_sessions/verify"
  devise_for :users,
    controllers: {
      registrations: 'users/registrations',
      sessions: 'users/sessions',
  }

  devise_scope :user do
    post 'users/send_otp', to: 'users/sessions#send_otp'
    post 'users/verify_otp', to: 'users/sessions#verify_otp'
    post 'users/password_login', to: 'users/sessions#password_login'
    post 'users/change_password', to: 'users/sessions#change_password'
    post 'users/forgot_password', to: 'users/sessions#forgot_password'
    post 'users/reset_password', to: 'users/sessions#reset_password'
    delete 'users/logout', to: 'users/sessions#logout'
  end

  namespace :api do
    namespace :v1 do
      get '/user/profile/:id', to: 'users#profile'
      put "/user/profile/:id", to: "users#update_profile"
      post "/user/profile/image/:id", to: "users#upload_profile_image"
    end
  end

  namespace :api do
    namespace :v1 do
      resources :addresses do
        member do
          patch :default
        end
      end
    end
  end

  namespace :api do
    namespace :v1 do
      resources :roles, only: [:index, :create]
      resources :categories

      # resources :restaurants


      # resources :tickets do
      #   resources :messages, controller: "ticket_messages", only: [:index, :create]
      # end




      resources :restaurants do
        member do
          get :generate_qr
        end
      end

      # Product Categories Routes
      resources :product_categories

      # Products Routes
      resources :products


      # resources :faqs, only: [:index]
      # resources :tickets, only: [:index, :create, :update]

      resources :faqs, only: [:index, :create, :destroy]
      # resources :tickets, only: [:index, :create]


      
      resources :tickets, only: [:index, :create, :update] do
        resources :messages, controller: "ticket_messages", only: [:index, :create]
      end


      resources :profile, only: [:index, :update]


      resources :categories
      resources :subcategories
      resources :states
      resources :cities
      # resources :user_details
      resources :user_details do
        member do
          patch :update_status
          patch :block
          patch :verify
        end
        collection do 
          post :import
        end 
      end
      # resources :rules
      resources :roles, only: [:index, :create, :update]
      resources :banners
      resources :coupons do
        member do
          post :redeem
        end
      end
      post "qr/scan", to: "qr#scan"
      post "coupons/create_from_event", to: "coupons#create_from_event"
      resources :offers
      resources :brands
      resources :subscription_plans
      resources :coupon_redemptions, only: [:index]
      resources :referral_plans, only: [:index, :create, :update, :destroy]
      resources :user_referrals, only: [:index, :update, :destroy]
      resources :payment_options, only: [:index, :create, :update, :destroy]
      resources :reviews do
        member do
          patch :toggle_visibility
        end
      end


    end
  end


    
    
    
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  # get  'otp_login',      to: 'otp_sessions#new',        as: :new_otp_session
  # post 'otp_login/send', to: 'otp_sessions#send_otp',   as: :send_otp
  # get  'otp_login/verify', to: 'otp_sessions#verify',   as: :verify_otp
  # post 'otp_login/confirm', to: 'otp_sessions#confirm_otp', as: :confirm_otp

  # # Password login after OTP
  # get  'password_login', to: 'password_sessions#new',  as: :password_login
  # post 'password_login', to: 'password_sessions#create'

  # Defines the root path route ("/")
  # root "posts#index"
end
# Rails.application.routes.draw do
#   # OTP session routes (if you still want them)
#   get "otp_sessions/new"
#   get "otp_sessions/verify"

#   # Devise routes
#   devise_for :users,
#     controllers: {
#       registrations: 'users/registrations',
#       sessions: 'users/sessions',
#     }

#   # Custom OTP & Password login routes for Devise users
#   devise_scope :user do
#     post 'users/send_otp', to: 'users/sessions#send_otp'
#     post 'users/verify_otp', to: 'users/sessions#verify_otp'
#     post 'users/password_login', to: 'users/sessions#password_login'
#   end

#   # Health check route
#   get "up" => "rails/health#show", as: :rails_health_check

#   # Legacy OTP login routes (optional, for older controllers)
#   get  'otp_login',        to: 'otp_sessions#new',        as: :new_otp_session
#   post 'otp_login/send',   to: 'otp_sessions#send_otp',   as: :send_otp
#   get  'otp_login/verify', to: 'otp_sessions#verify',     as: :verify_otp
#   post 'otp_login/confirm', to: 'otp_sessions#confirm_otp', as: :confirm_otp

#   # Password login after OTP (legacy controller)
#   get  'password_login', to: 'password_sessions#new',  as: :password_login
#   post 'password_login', to: 'password_sessions#create'

#   # Root route (optional)
#   # root "posts#index"
# end
