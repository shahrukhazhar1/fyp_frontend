Rails.application.routes.draw do
  # devise_for :quiz_users
  root to: 'quiz_creation#index'
  devise_for :quiz_users, controllers: { registrations: "quiz_users/registrations", confirmations: "quiz_users/confirmations", sessions:"quiz_users/sessions" }

  resources :quiz_creation do
    collection do
      get :tutorials
      get :rejected_quizzes
      get :approved_quizzes
      get :submitted_quizzes
      get :unfinished_quizzes
    end
  end
  devise_scope :quiz_user do
    match 'login'            => 'quiz_users/sessions#create',         :via => :post
    match 'signup'           => 'quiz_users/registrations#create',    :via => :post
    # match 'logout'           => 'quiz_users/sessions#destroy',        :via => :get
  end
  resources :courses
  resources :labels


  resources :quizzes do
    member do
      get :approve
      get :reject
      get :new_verison
      get :submit_for_approval
      get :study_guide
    end
    collection do
      get :quiz_results
    end
    resources :questions, :except => [:index] do
      member do
        put :change_order
      end
    end
  end

  get '/quiz_user_account', to: 'quiz_creation#quiz_user_account'
  post '/settings', to: 'quiz_creation#settings'
  post '/check_email', to: 'quiz_creation#check_email'
  post '/set_comment', to: 'quizzes#set_comment'
  post '/set_question_comment', to: 'questions#set_question_comment'
  post '/switch_alerts', to: 'quiz_creation#switch_alerts'
  get '/messages', to: 'quiz_creation#messages'

  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  post '/set_sample_question', to: 'quiz_creation#set_sample_question'
  match '*path' => redirect('/'), via: :get
end
