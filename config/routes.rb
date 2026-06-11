Rails.application.routes.draw do
  root "home#index"

  scope "/examples", as: :examples do
    # Example 1 — modal + form swap
    get  "tasks",                    to: "tasks#index",          as: :tasks
    get  "tasks/modal_body",         to: "tasks#modal_body",     as: :tasks_modal_body
    post "tasks/run",                to: "tasks#run",            as: :tasks_run

    # Example 2 — inline form validation
    get  "signups/new",              to: "signups#new",          as: :new_signup
    get  "signups/check_username",   to: "signups#check_username", as: :check_username_signup
    post "signups",                  to: "signups#create",       as: :signups

    # Example 3 — click-to-load
    get  "articles",                 to: "articles#index",       as: :articles
    get  "articles/:id/preview",     to: "articles#preview",     as: :article_preview
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
