Rails.application.routes.draw do
  post '/service/:service_slug/user/:user_id', to: 'user_file#create'
end
