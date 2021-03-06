ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # is there a bulletin to use?
  #map.connect ':project/bulletin/:bulletin/:action', :controller => 'bulletins'

  map.connect 'stats/add/:id.png', :controller => 'stats', :action => 'add'

  map.connect 'admin', :controller => 'admin/user', :action => 'login'
  
  # default routes that do not require :project_name infront (this is a pain)
  # map.connect 'admin/projects/:action/:id', :controller => 'admin/projects'
  # map.connect 'admin/users/:action/:id', :controller => 'admin/users'
  # map.connect 'admin/recipients/:action/:id', :controller => 'admin/recipients'
  map.namespace :admin do |admin|
    admin.connect 'user/:action', :controller => 'user'
    admin.resources :users
    admin.resources :recipients
    admin.resources :project_groups do |project_group|
      project_group.resources :recipient_meta_options
    end
    admin.resources :projects do |project|
      project.connect 'files/:action', :controller => 'files'
      project.resources :bulletins, :member => {:live_edit => :get, :preview => :any,
          :copy => :post, :send_test => :any, :send_bulletin => :any, :abort_send => :any,
          :stats => :get, :preview_edit => :get, :live_edit_header => :get} do |bulletin|
        bulletin.resources :sections do |section|
          section.resources :entries, :member => {:move_up => :get, :move_down => :get}
        end
      end
      project.resources :content_pages
      project.resources :subscriptions
      project.resources :user_roles
      project.resources :templets, :collection => {:help => :get}, :member => {:send_test => :any} do |templates|
        templates.resources :templet_layouts, :member => {:choose_form => :any},
          :name_prefix => 'admin_project_', :as => 'layouts'
        templates.resources :templet_layouts, :member => {:choose_form => :any}
      end
    end
    # templates provided twice!
    admin.resources :templets, :collection => {:help => :get}, :member => {:send_test => :any} do |templates|
      templates.resources :templet_layouts, :member => {:choose_form => :any},
          :name_prefix => 'admin_', :as => 'layouts'
      templates.resources :templet_layouts, :member => {:choose_form => :any}
    end
  end

  # Routes used by subscribers to ease visuals
  map.connect ':project_name/bulletin/:bulletin_title', :controller => 'bulletins', :action => 'show'
  map.connect ':project_name/bulletin/:bulletin_title/:page_name', :controller => 'content', :action => 'page'
  map.connect ':project_name/subscribe', :controller => 'recipients', :action => 'subscribe'
  map.connect ':project_name/unsubscribe', :controller => 'recipients', :action => 'unsubscribe'
  map.connect ':project_name/confirm', :controller => 'recipients', :action => 'confirm'
  map.connect ':project_name/archive.:format', :controller => 'bulletins', :action => 'list'
  map.connect ':project_name/archive', :controller => 'bulletins', :action => 'list'
  map.connect ':project_name/forward/:bulletin_title', :controller => 'forward', :action => 'bulletin'
  map.connect ':project_name/forward/:bulletin_title/:page_name', :controller => 'forward', :action => 'page'

  # map the project if its provided
  map.connect ':project_name', :controller => 'projects', :action => 'show'
  map.connect ':project_name/:controller/:action/:id'
  
  # Install the default route as the lowest priority.
  # map.connect ':controller/:action/:id'
end
