Rails.application.routes.draw do

if defined?(Rswag::Api)
  mount Rswag::Api::Engine => "/api-docs"
end

if defined?(Rswag::Ui)
  mount Rswag::Ui::Engine  => "/api-docs"
end

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
      namespace :merchant do

        get    'offers/stats',      to: 'offers#stats'
        get    'offers',            to: 'offers#index'
        get    'offers/list',       to: 'offers#list'
        get    'offers/analytics',  to: 'offers#analytics'
        get    'offers/banners',    to: 'offers#banners'

        post   'offers/create',              to: 'offers#create'
        put    'offers/update/:id',          to: 'offers#update'
        delete 'offers/delete/:id',          to: 'offers#destroy'
        get    'offers/:id',                 to: 'offers#show'

      end
    end
  end

  namespace :api do
    namespace :v1 do
      namespace :merchant do

        resources :merchant_restaurants,
                  param: :restaurant_id,
                  only: [:index, :show, :create, :update, :destroy] do

          collection do
            get :stats
            get :filter
            get :analytics
            get :dashboard
            get :list
          end

          member do
            get :gallery
            patch :settings
          end

        end

      end
    end
  end

  namespace :api do
    namespace :v1 do
      namespace :merchant do

        resources :deals,
                  param: :deal_code do

          collection do
            get :stats
            get :analytics
            get :dashboard
            get :filter
            get :list
          end

        end

      end
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
      namespace :merchant do 
        get "dashboard/stats", to: "dashboard#stats" 
        get "dashboard/coupon_usage", to: "dashboard#coupon_usage"
        get "dashboard/revenue_analytics", to: "dashboard#revenue_analytics"
        get "dashboard/top_coupons", to: "dashboard#top_coupons"
        get "redemptions/latest", to: "redemptions#latest"
        get "reviews", to: "reviews#index"
      end 
    end 
  end

  namespace :api do
    namespace :v1 do
      namespace :merchant do

        get  "locations/stats", to: "merchant_locations#stats"
        get  "locations/filter", to: "merchant_locations#filter"
        get  "locations/list", to: "merchant_locations#list"

        post "locations/create", to: "merchant_locations#create"

        put  "locations/update/:location_id", to: "merchant_locations#update"

        
        get  "locations/staff/:location_id", to: "merchant_locations#staff"
        
        get  "locations/analytics", to: "merchant_locations#analytics"
        
        get  "locations/dashboard", to: "merchant_locations#dashboard"
        get  "locations/:location_id", to: "merchant_locations#show"

      end
    end
  end

  namespace :api do
    namespace :v1 do
      namespace :merchant do

        get "redemptions/stats", to: "merchant_redemptions#stats"
        get "redemptions/filter", to: "merchant_redemptions#filter"
        get "redemptions/list", to: "merchant_redemptions#index"
        get "redemptions/recent", to: "merchant_redemptions#recent"
        get "redemptions/pending", to: "merchant_redemptions#pending"
        get "redemptions/analytics", to: "merchant_redemptions#analytics"

        get "redemptions/:redemption_id",
            to: "merchant_redemptions#show"

        patch "redemptions/verify/:redemption_id",
              to: "merchant_redemptions#verify"

        patch "redemptions/reject/:redemption_id",
              to: "merchant_redemptions#reject"

      end
    end
  end
  
  namespace :api do
    namespace :v1 do
      namespace :merchant do
        resources :customers, only: [:show], param: :customer_id do
          collection do
            get :stats
            get :filter
            get :list
            get :analytics
          end

          member do
            get :activity
          end
        end
      end
    end
  end

  namespace :api do
    namespace :v1 do
      namespace :merchant do
        resources :support_tickets
      end
    end
  end

  namespace :api do
    namespace :v1 do
      namespace :merchant do
        
        get "coupons/analytics",
            to: "merchant_coupons#analytics"

        get "coupons/filter",
            to: "merchant_coupons#filter"

        get "coupons/expiry-alerts",
            to: "merchant_coupons#expiry_alerts"

        get    "coupons/stats",
              to: "merchant_coupons#stats"

        get    "coupons",
              to: "merchant_coupons#index"

        post   "coupons/create",
              to: "merchant_coupons#create"

        get    "coupons/:coupon_id",
              to: "merchant_coupons#show"

        put    "coupons/update/:coupon_id",
              to: "merchant_coupons#update"

        delete "coupons/delete/:coupon_id",
              to: "merchant_coupons#destroy"

      end
    end
  end

  namespace :api do
    namespace :v1 do
      namespace :user do
        post "2fa/enable", to: "two_factor#enable"
        post "2fa/verify", to: "two_factor#verify"
        post "2fa/disable", to: "two_factor#disable"
        get "login_activity/:user_id", to: "users#login_activity"
        get "login_activity", to: "profiles#login_activity"
        post "logout_all", to: "profiles#logout_all"
        get 'data-export', to: 'profiles#download'
      end
    end
  end

  namespace :api do
    namespace :v1 do
      namespace :user do
        resource :privacy, only: [:show, :update], controller: "privacy"
        resource :notifications, only: [:show, :update]
        get  "notifications/feed",          to: "notifications#feed"
        patch "notifications/:id/read",     to: "notifications#mark_as_read"
        patch "notifications/read-all",     to: "notifications#mark_all_as_read"
        delete "notifications/:id",         to: "notifications#destroy"
        get  "notifications/unread-count",  to: "notifications#unread_count"
        get "preferences", to: "preferences#show"
        put "preferences", to: "preferences#update"
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
#  mount Rswag::Api::Engine => '/api-docs'
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
