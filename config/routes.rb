TechnologyBlog::Application.routes.draw do
  
  devise_for :users,:controllers => { 
    :omniauth_callbacks => "users/omniauth_callbacks"
  }
  
  get 'users/:user_id/blogs/import/new' => 'blogs#import_new' ,:as => 'import_new_user_blog'
  post 'users/:user_id/blogs/import' => 'blogs#import_create' ,:as => 'import_user_blog'
  get 'users/:user_id/blogs/export' => 'blogs#export',:as => "export_user_blog"
  
  resources :users,:only => ['index','destroy'] do
    resources :blogs 
  end
  
  root :to => "users#index"
  
end
