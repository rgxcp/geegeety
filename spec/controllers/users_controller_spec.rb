ENV["APP_ENV"] = "test"

require_relative "../../app/controllers/api/v1/users_controller"

describe UsersController do
  def app
    UsersController
  end

  let(:user) { double }

  context "when doesn't pass validation" do
    it "will return 403 with errors" do
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

  context "when passed validation" do
    it "will return 201 with generated user data" do
      allow(User)
        .to receive(:new)
        .and_return(user)

      allow(user)
        .to receive(:save)
        .and_return({
          :success => true,
          :errors => [],
          :user => {
            :id => 2,
            :username => "johndoe",
            :email => "johndoe@gmail.com",
            :bio => "Backend Student",
            :created_at => "2021-08-21 20:08:21 +0700"
          }
        })

      post "/api/v1/users"

      expect(last_response).to be_created
      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq({
        :status => "Success",
        :data => {
          :user => {
            :id => 2,
            :username => "johndoe",
            :email => "johndoe@gmail.com",
            :bio => "Backend Student",
            :created_at => "2021-08-21 20:08:21 +0700"
          }
        }
      }.to_json)
    end
  end
end
