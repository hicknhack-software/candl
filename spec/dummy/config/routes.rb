Rails.application.routes.draw do
  get "calendar" => "sample#show"
  mount Candle::Engine => "/candle"
end
