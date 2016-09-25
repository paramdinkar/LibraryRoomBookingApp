Rails.application.routes.draw do
  get 'library/home'
  get 'reservations/newreservation' => 'reservations#newreservation'
  post 'reservations/new' => 'reservations#createreservation'
  get 'reservations/managereservation' => 'reservations#managereservation'
  get 'members/managereservation' => 'members#managereservation'
  get 'admins/managereservation' => 'admins#managereservation'
  get 'admins/managemember' => 'admins#managemember'
  get 'reservations/manageadminreservation' => 'reservations#manageadminreservation'
  get 'members/signin' => 'members#signin'
  post 'members/welcome' => 'members#welcome'
  get 'members/homepage' => 'members#homepage'
  get 'admins/homepage' => 'admins#homepage'
  get 'members/welcome' => 'members#welcome'
  get 'admins/welcome' => 'admins#welcome'
  get 'admins/signin' => 'admins#signin'
  post 'admins/welcome' => 'admins#welcome'
  get 'members/addPermission' => 'members#addPermission'
  put 'members/updatePermissionForMultipleReservations' => 'members#updatePermissionForMultipleReservations'
  get 'admins/getmembersWithMultipleReservation' => 'admins#getmembersWithMultipleReservation'
  get 'members/pastReservations' => 'members#pastReservations'
  get 'members/search' => 'members#searchRooms'
  post 'members/searchFilter' => 'members#searchFilter'
  resources :reservations
  resources :rooms
  resources :members
  resources :admins

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'library#home'

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
