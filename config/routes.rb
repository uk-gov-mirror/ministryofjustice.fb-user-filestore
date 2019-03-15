Rails.application.routes.draw do
  get '/service/:service_slug/user/:user_id/:fingerprint_with_prefix', to: 'downloads#show'
  post '/service/:service_slug/user/:user_id', to: 'uploads#create'
end
