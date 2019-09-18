Rails.application.routes.draw do
  get '/health', to: 'health#show'
  get '/service/:service_slug/user/:user_id/:fingerprint_with_prefix', to: 'downloads#show'
  post '/service/:service_slug/user/:user_id', to: 'uploads#create'
  post '/service/:service_slug/user/:user_id/public-file', to: 'public_files#create'
end
