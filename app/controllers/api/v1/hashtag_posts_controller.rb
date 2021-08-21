require_relative "application_controller"
require_relative "../../../models/hashtag"

class HashtagPostsController < ApplicationController
  get "/api/v1/hashtags/:name/posts" do
    posts = Hashtag.posts(params[:name])

    if posts.size > 0
      status 200
      result = {
        :status => "Success",
        :data => {
          :posts => posts
        }
      }
    else
      status 404
      result = {
        :status => "Success",
        :message => "Not Found"
      }
    end

    result.to_json
  end
end
