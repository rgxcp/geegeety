require_relative "application_controller"
require_relative "../../../models/comment"

class PostCommentsController < ApplicationController
  post "/api/v1/posts/:post_id/comments" do
    comment = Comment.new(params)
    comment = comment.save

    if comment[:success]
      status 201
      result = {
        :status => "Success",
        :data => {
          :comment => comment[:comment]
        }
      }
    else
      status 403
      result = {
        :status => "Failed",
        :errors => comment[:errors]
      }
    end

    result.to_json
  end
end
