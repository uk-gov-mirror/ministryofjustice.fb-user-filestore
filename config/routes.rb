Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/service/:service_slug/user/:user_id', to: 'user_file#create'
end
