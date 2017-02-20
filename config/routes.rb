Rails.application.routes.draw do
  post "/" => "google_assistant#conversation"
  get "/oauth" => "oauth#authorize"
  post "/oauth/token" => "oauth#token"
end
