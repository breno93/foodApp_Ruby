Rails.application.routes.draw do
  namespace :admin do
    resources :products
    resources :categories
  end
  devise_for :admins

  # Verificando se o usuário está autenticado (admin) e direcionando para a página.
  authenticated :admin do
    root to: "admin#index", as: :admin_root
  end

  get "admin" => "admin#index"
  root "home#index"
end
