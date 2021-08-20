ENV["APP_ENV"] = "test"

require_relative "../../app/controllers/post_comments_controller"

describe PostCommentsController do
  def app
    PostCommentsController
  end

  context "when doesn't pass validation" do
    it "will return 403 with errors" do
      comment = double
      allow(Comment)
        .to receive(:new)
        .and_return(comment)

      allow(comment)
        .to receive(:save)
        .and_return({
          :success => false,
          :errors => [
            "User Id can't be nil or empty.",
            "Body can't be nil or empty."
          ]
        })

      post "/api/v1/posts/:post_id/comments"

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
