require_relative "application_controller"
require_relative "../models/post"

class PostsController < ApplicationController
  post "/api/v1/posts" do
    post = Post.new(params)
    post = post.save

    status 403
    result = {
      :status => "Failed",
      :errors => post[:errors]
    }
    result.to_json
  end
end
