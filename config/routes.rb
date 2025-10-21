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
