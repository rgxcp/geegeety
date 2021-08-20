ENV["APP_ENV"] = "test"

require_relative "../../app/controllers/users_controller"

describe UsersController do
  def app
    UsersController
  end

  context "when doesn't pass validation" do
    it "will return 403 with errors" do
      user = double
      allow(User)
        .to receive(:new)
        .and_return(user)

      allow(user)
        .to receive(:save)
        .and_return({
          :success => false,
          :errors => [
            "Username can't be nil or empty.",
            "Email can't be nil or empty.",
            "Bio can't be nil or empty."
          ]
        })

      post "/api/v1/users"

      expect(last_response).to be_forbidden
      expect(last_response.status).to eq(403)
      expect(last_response.body).to eq({
        :status => "Failed",
        :errors => [
          "Username can't be nil or empty.",
          "Email can't be nil or empty.",
          "Bio can't be nil or empty."
        ]
      }.to_json)
    end
  end
end
