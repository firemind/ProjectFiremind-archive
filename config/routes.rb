Firemind::Application.routes.draw do
  resources :duel_queues
  resources :not_implementable_reasons
  resources :ai_rating_matches, except: [:update, :edit, :destroy] do
    member do
      get :diff
    end
    collection do
      get 'compare/:ai_name/:identifier', to: 'ai_rating_matches#compare_by_identifier', as: :compare_by_idf
      get 'compare/:ai_name', to: 'ai_rating_matches#compare', as: :compare
    end
  end

  resources :sideboard_suggestions, only: [:show] do
    member do 
      post :copy
      post :paste
    end
  end
  resources :sideboard_plans, only: [] do
    collection do
      post :copy
      post :paste
    end
  end

  resources :workspace, only: [:index] do
    post :add, on: :member
    delete :destroy, on: :member
  end
  resources :dealt_hands, only: [:show] do
    member do
      get :keep
      get :mulligan
      get :tooltip
    end
    collection do
      get :sample
      get :export
    end
  end

  get "/mulligan", to: "dealt_hands#sample"

  devise_for :admins, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  require 'sidekiq/web'
  authenticate :admin do
    mount Sidekiq::Web => '/sidekiq'
  end
  devise_for :users, controllers: {omniauth_callbacks: "omniauth_callbacks"}
  resources :users, except: [:index, :create, :new, :destroy] do
    member do
      resources :card_script_claims, only: [:index]
    end
    get 'my_token', on: :collection
    post :generate_access_token, on: :collection
    post :follow, on: :member
    post :unfollow, on: :member
  end
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure', to: redirect('/')

  resources :formats, only: [:show] do
    member do
      get 'top_ratings_chart_data'
      get 'top_cards'
      get 'deck_lists'
      get 'decks'
      get 'cards'
      get 'editions'
      get 'restricted_cards'
    end
    collection do
      get :diff
    end
    get 'archetypes(.:format)' => "archetypes#index", as: :archetypes
    get 'archetypes/:id(.:format)' => "archetypes#show", as: :archetype
  end
  get '/formats/:id', to: 'formats#show'

  resources :card_script_submissions, only: [:new, :create, :show] do
    get :my, on: :collection
    post :force_submit, on: :member
  end

  resources :editions, only: [:show, :index] do
    get 'visual', on: :member
  end
  get "editions/:set_code/cards(.:format)" => "editions#cards"

  resources :tournaments, only: [:show, :index]

  resources :deck_challenges do 
    member do
      get :challenger_select
      patch :close
      post :run_more
    end
  end
  resources :challenge_entries, only: [:create]

  resources :archetypes, only: [:index, :show] do
    collection do
      get :decklists
      get :classify
      post "classify" => "archetypes#classify_deck"
      get :compare
      patch :reassign
      patch :merge
    end
    member do
      get :compare_select
      get 'deck_lists_by_card/:card_id' => :deck_lists_by_card, as: :deck_lists_by_card
    end
    resources :deck_lists, only: :index
    resources :decks, only: :index
  end

  resources :meta, only: [:index, :create, :update] do
    post :run, on: :member
    collection do
      get 'my/:format_id', to: 'meta#my', as: 'my'
    end
  end
  namespace :api do
    namespace :v1 do
      resource :mulligans, only: [] do
        get :hands
        get :established_hands
        get :decks
        get "decks/:deck_list_id/hands" => "mulligans#hands_by_deck"
        get "hand/:id" => "mulligans#hand"
        post "hand/:id/keep" => "mulligans#keep"
        post "hand/:id/mulligan" => "mulligans#mulligan"
      end
      resource :airm, only: [] do
        get :fetch
      end
      resource :duels, only: [] do
        post :create
      end
      resource :decks, only: [] do
        post :create
      end
      resource :archetypes, only: [] do
        post :classify
      end
      delete "duel_jobs" => "duel_jobs#pop"
      resources :duel_jobs, only: [] do
        member do
          post :post_failure
          post :post_success
        end
        collection do
        end
        resources :games, only: [:create]
      end
      resource :status, only: [] do
        get 'client_info', action: :client_info
      end
    end
    namespace :v2 do
      mount_devise_token_auth_for 'User', at: 'auth'
      resources :duels do 
        get 'my', on: :collection
      end
      resources :devices do 
        post 'register', on: :collection
      end
      resources :users do 
        get 'profile', on: :collection
      end
    end
  end

  resources :archetype_confirmation do
    member do
      patch :confirm
    end
  end

  resources :deck_entry_clusters, only: [:show, :new, :create] do
    post :addto, on: :collection
    post :delfrom, on: :collection
  end
  resources :deck_lists, only: [:show] do
    member do
      get :challenge_with
      post :follow
      post :unfollow
      get :fetch_games
      post :fork
      get :show_cards
      get :change_archetype
      get :dealt_hands
      get 'matchup/:archetype_id'=> 'deck_lists#matchup', as: :matchup
      get :tooltip
      get :list
      patch :update
      get 'ratings_chart_data/:format_id' => 'deck_lists#ratings_chart_data', as: :ratings_chart_data
      get 'ratings/:rating_id' => 'deck_lists#ratings', as: :ratings
    end
  end
  resources :decks do
    member do
      get :sideboarding
      get :sideboarding_suggestions
      get :mulligans
      get :calculate_sideboard
      post :add_sideboard_plan
      patch :update_sideboard_plan
      patch :update_thumb
      post 'copy_sideboard_plan/:deck_list_id' => "decks#copy_sideboard_plan", as: 'copy_sideboard_plan'
      delete :remove_sideboard_plan
      get :embed
      get 'format/:format_id' => 'decks#format', as: 'format'
      get 'diff/:other_deck_id' => 'decks#diff', as: 'diff'
    end
    resources :duels, only: [:index]
    collection do
      get 'my(/:deck_format)', action:'my', as: 'my',defaults: { deck_format: 'standard'}
      get :top
      get :generate
      get :search
      get :search_suggestions
      get "generate_from_archetype/:archetype_id", action: :generate_from_archetype, as: "generate_from_archetype"
    end
    resources :deck_entry_clusters, only: [:show, :new, :create] do
      get :assign, on: :collection
      get :playable_hand, on: :collection
    end
    resources :maybe_entries, except: [:index, :show]
  end

  resources :card_requests, only: [:show, :create] do
    member { post :vote }
  end

  resources :duels, except: [:destroy] do
    collection {
      get :my
      get :search_decks
      post 'challenge_top/:format_id/:deck_id', action: 'challenge_top', as: 'challenge_top'
    }
    member {
      get 'box'
    }
    resources :games, only: [:index]
  end

  get "/about" => 'main#about', as: 'about'
  get "/status" => 'main#status', as: 'status'

  resources :games, only: [:index, :show]

  #resources :ai_mistakes, only: [:new, :create]

  resources :cards, only: [:index, :show] do
    get :tooltip, on: :member
    get :search, on: :collection
    get :enabled, on: :collection
    get :disabled, on: :collection
    get :scripts, on: :member
    get :all, on: :collection
    get :missing, on: :collection
    patch :add_unimplementable_reasons, on: :member
  end

  get '/create_guest/' => "users#create_guest_user"
  post '/request_card/:card_id' => "card_requests#create", as: :request_card
  #get '/report_ai_mistake/:game_id/:line_number' => "ai_mistakes#new"
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".


  # You can have the root of your site routed with "root"
  root 'main#home'

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
end
