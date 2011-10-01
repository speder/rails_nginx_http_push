HttpPush::Application.routes.draw do
  resources :jobs, :only => [:index, :new, :create]
  root :to => 'jobs#index'
end
