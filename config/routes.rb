Rails.application.routes.draw do
  root "home#index"

  scope "/examples", as: :examples do
    # Example 1 — modal + form swap
    get  "reports",                  to: "reports#index",        as: :reports
    get  "reports/modal_body",       to: "reports#modal_body",   as: :reports_modal_body
    post "reports/submit_year",      to: "reports#submit_year",  as: :reports_submit_year

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
