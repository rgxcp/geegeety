require_relative "application_controller"
require_relative "../../../models/post"

class PostsController < ApplicationController
  post "/api/v1/posts" do
    post = Post.new(params)
    post = post.save

    if post[:success]
      status 201
      result = {
        :status => "Success",
        :data => {
          :post => post[:post]
        }
      }
    else
      status 403
      result = {
        :status => "Failed",
        :errors => post[:errors]
      }
    end

    result.to_json
  end
end
