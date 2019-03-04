Rails.application.routes.draw do
  get '/service/:service_slug/user/:user_id/:fingerprint', to: 'user_file#show'
  post '/service/:service_slug/user/:user_id', to: 'user_file#create'
end
