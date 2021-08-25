require_relative "../api_controller"
require_relative "../../../models/hashtag"

class HashtagPostsController < APIController
  get "/api/v1/hashtags/:name/posts" do
    posts = Hashtag.posts(params[:name])

    if posts.size > 0
      status 200
      response = {
        :status => "Success",
        :data => {
          :posts => posts
        }
      }
    else
      status 404
      response = {
        :status => "Success",
        :message => "Not Found"
      }
    end

    response.to_json
  end
end
