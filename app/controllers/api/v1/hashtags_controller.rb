require_relative "../api_controller"
require_relative "../../../models/hashtag"

class HashtagsController < APIController
  get "/api/v1/hashtags/trending" do
    hashtags = Hashtag.trending

    status 200
    response = {
      :status => "Success",
      :data => {
        :hashtags => hashtags
      }
    }
    response.to_json
  end
end
