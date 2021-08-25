require_relative "../api_controller"
require_relative "../../../models/hashtag"

class HashtagsController < APIController
  get "/api/v1/hashtags/trending" do
    hashtags = Hashtag.trending

    status 200
    result = {
      :status => "Success",
      :data => {
        :hashtags => hashtags
      }
    }
    result.to_json
  end
end
