Rails.application.routes.draw do
  get '/llm', to: 'llm#new'
  post '/llm', to: 'llm#create'
end