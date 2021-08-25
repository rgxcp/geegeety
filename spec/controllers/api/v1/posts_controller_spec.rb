ENV["APP_ENV"] = "test"

require_relative "../../../../app/controllers/api/v1/posts_controller"

describe PostsController do
  def app
    PostsController
  end

  let(:user_post) { double }

  context "when doesn't pass validation" do
    it "will return 403 with errors" do
      allow(Post)
        .to receive(:new)
        .and_return(user_post)

      allow(user_post)
        .to receive(:save)
        .and_return({
          :success => false,
          :errors => [
            "User Id can't be nil or empty.",
            "Body can't be nil or empty."
          ]
        })

      post "/api/v1/posts"

      expect(last_response).to be_forbidden
      expect(last_response.status).to eq(403)
      expect(last_response.body).to eq({
        :status => "Failed",
        :errors => [
          "User Id can't be nil or empty.",
          "Body can't be nil or empty."
        ]
      }.to_json)
    end
  end

  context "when passed validation" do
    it "will return 201 with generated post data" do
      allow(Post)
        .to receive(:new)
        .and_return(user_post)

      allow(user_post)
        .to receive(:save)
        .and_return({
          :success => true,
          :errors => [],
          :post => {
            :id => 1,
            :user_id => 2,
            :body => "Hello, World! #backend",
            :attachment => "http://localhost:4567/api/v1/attachments/20210821200821.jpg",
            :hashtags => [{
              :id => 1,
              :hashtagable_id => 1,
              :hashtagable_type => "POST",
              :name => "backend",
              :created_at => "2021-08-21 20:08:21 +0700"
            }],
            :created_at => "2021-08-21 20:08:21 +0700"
          }
        })

      post "/api/v1/posts"

      expect(last_response).to be_created
      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq({
        :status => "Success",
        :data => {
          :post => {
            :id => 1,
            :user_id => 2,
            :body => "Hello, World! #backend",
            :attachment => "http://localhost:4567/api/v1/attachments/20210821200821.jpg",
            :hashtags => [{
              :id => 1,
              :hashtagable_id => 1,
              :hashtagable_type => "POST",
              :name => "backend",
              :created_at => "2021-08-21 20:08:21 +0700"
            }],
            :created_at => "2021-08-21 20:08:21 +0700"
          }
        }
      }.to_json)
    end
  end
end
