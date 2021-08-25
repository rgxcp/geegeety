require_relative "../api_controller"
require_relative "../../../models/comment"

class PostCommentsController < APIController
  post "/api/v1/posts/:post_id/comments" do
    comment = Comment.new(params)
    comment = comment.save

    if comment[:success]
      status 201
      response = {
        :status => "Success",
        :data => {
          :comment => comment[:comment]
        }
      }
    else
      status 403
      response = {
        :status => "Failed",
        :errors => comment[:errors]
      }
    end

    response.to_json
  end
end
