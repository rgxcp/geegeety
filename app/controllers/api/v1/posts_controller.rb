require_relative "../api_controller"
require_relative "../../../models/post"

class PostsController < APIController
  post "/api/v1/posts" do
    post = Post.new(params)
    post = post.save

    if post[:success]
      status 201
      response = {
        :status => "Success",
        :data => {
          :post => post[:post]
        }
      }
    else
      status 403
      response = {
        :status => "Failed",
        :errors => post[:errors]
      }
    end

    response.to_json
  end
end
