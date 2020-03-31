Rails.application.routes.draw do

  #welcome路由
  get 'welcome/index'
  
  resources :articles
  
  root 'welcome#index'
  
  #sandylai路由
  get 'sandylai/index'
  
  resources :articles
  
  root 'sandylai#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
