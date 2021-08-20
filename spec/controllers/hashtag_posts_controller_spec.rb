ENV["APP_ENV"] = "test"

require_relative "../../app/controllers/hashtag_posts_controller"

describe HashtagPostsController do
  def app
    HashtagPostsController
  end

  context "when there's no posts for a hashtag" do
    it "will return 404 with not found message" do
      get "/api/v1/hashtags/:name/posts"

      expect(last_response).to be_not_found
      expect(last_response.status).to eq(404)
      expect(last_response.body).to eq({
        :status => "Success",
        :message => "Not Found"
      }.to_json)
    end
  end
end
