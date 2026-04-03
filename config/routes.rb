Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      # Authentication
      post "/login", to: "auth#login"
      post "/register", to: "auth#register"

      # Medical Report APIs
      post "/upload_report", to: "reports#upload"
      get "/medical_reports", to: "reports#index"
      get "/medical_reports/:id", to: "reports#show"
      get "health_trend", to: "reports#health_trend"
      get "/dashboard", to: "reports#dashboard"
      delete "/medical_reports/:id", to: "reports#destroy"

    end
  end
end