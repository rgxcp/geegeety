ENV["APP_ENV"] = "test"

require_relative "../../../../app/controllers/api/v1/hashtag_posts_controller"

describe HashtagPostsController do
  def app
    HashtagPostsController
  end

  context "when there's no posts for a hashtag" do
    it "will return 404 with not found message" do
      allow(Hashtag)
        .to receive(:posts)
        .and_return([])

      get "/api/v1/hashtags/:name/posts"

      expect(last_response).to be_not_found
      expect(last_response.status).to eq(404)
      expect(last_response.body).to eq({
        :status => "Success",
        :message => "Not Found"
      }.to_json)
    end
  end

  context "when there's posts for a hashtag" do
    it "will return 200 with posts data" do
      allow(Hashtag)
        .to receive(:posts)
        .and_return([{
          :id => 1,
          :user_id => 2,
          :body => "Hello, World! #backend",
          :attachment => "http://localhost:4567/api/v1/attachments/20210821200821.jpg",
          :created_at => "2021-08-21 20:08:21 +0700"
        }])
  
      get "/api/v1/hashtags/:name/posts"
  
      expect(last_response).to be_ok
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq({
        :status => "Success",
        :data => {
          :posts => [{
            :id => 1,
            :user_id => 2,
            :body => "Hello, World! #backend",
            :attachment => "http://localhost:4567/api/v1/attachments/20210821200821.jpg",
            :created_at => "2021-08-21 20:08:21 +0700"
          }]
        }
      }.to_json)
    end
  end
end
