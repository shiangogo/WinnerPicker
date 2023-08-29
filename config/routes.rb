Rails.application.routes.draw do
  root to: "home#index"
  post "/callback", to: "line_bot#callback"
end
