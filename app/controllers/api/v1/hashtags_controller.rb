require_relative "application_controller"
require_relative "../../../models/hashtag"

class HashtagsController < ApplicationController
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
