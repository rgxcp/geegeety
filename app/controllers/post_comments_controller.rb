require_relative "application_controller"
require_relative "../models/comment"

class PostCommentsController < ApplicationController
  post "/api/v1/posts/:post_id/comments" do
    comment = Comment.new(params)
    comment = comment.save

    status 403
    result = {
      :status => "Failed",
      :errors => comment[:errors]
    }
    result.to_json
  end
end
