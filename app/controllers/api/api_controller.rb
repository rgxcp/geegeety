require "sinatra/base"

class APIController < Sinatra::Base
  set :default_content_type, "application/json"
end
