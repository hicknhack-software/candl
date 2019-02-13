Rails.application.routes.draw do
  get "calendar" => "sample#show"
  mount Candl::Engine => "/candl"
end
