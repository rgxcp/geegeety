require_relative "application_controller"
require_relative "../models/hashtag"

class HashtagPostsController < ApplicationController
  get "/api/v1/hashtags/:name/posts" do
    status 404
    result = {
      :status => "Success",
      :message => "Not Found"
    }
    result.to_json
  end
end
