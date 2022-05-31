Rails.application.routes.draw do
  root "sample#show"
  mount Candl::Engine => "/candl"
end
