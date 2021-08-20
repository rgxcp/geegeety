ENV["APP_ENV"] = "test"

require_relative "../../app/controllers/posts_controller"

describe PostsController do
  def app
    PostsController
  end

  context "when doesn't pass validation" do
    it "will return 403 with errors" do
      post = double
      allow(Post)
        .to receive(:new)
        .and_return(post)

      allow(post)
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
end
