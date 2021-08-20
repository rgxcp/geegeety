ENV["APP_ENV"] = "test"

require_relative "../../app/controllers/post_comments_controller"

describe PostCommentsController do
  def app
    PostCommentsController
  end

  let(:comment) { double }

  context "when doesn't pass validation" do
    it "will return 403 with errors" do
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

  context "when passed validation" do
    it "will return 201 with generated comment data" do
      allow(Comment)
        .to receive(:new)
        .and_return(comment)

      allow(comment)
        .to receive(:save)
        .and_return({
          :success => true,
          :errors => [],
          :comment => {
            :id => 1,
            :user_id => 2,
            :post_id => 1,
            :body => "Hello too, World! #backend",
            :attachment => "20210821200821.jpg",
            :hashtags => [{
              :id => 1,
              :hashtagable_id => 1,
              :hashtagable_type => "COMMENT",
              :name => "backend",
              :created_at => "2021-08-21 20:08:21"
            }],
            :created_at => "2021-08-21 20:08:21"
          }
        })

      post "/api/v1/posts/:post_id/comments"

      expect(last_response).to be_created
      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq({
        :status => "Success",
        :data => {
          :comment => {
            :id => 1,
            :user_id => 2,
            :post_id => 1,
            :body => "Hello too, World! #backend",
            :attachment => "20210821200821.jpg",
            :hashtags => [{
              :id => 1,
              :hashtagable_id => 1,
              :hashtagable_type => "COMMENT",
              :name => "backend",
              :created_at => "2021-08-21 20:08:21"
            }],
            :created_at => "2021-08-21 20:08:21"
          }
        }
      }.to_json)
    end
  end
end
