ENV["APP_ENV"] = "test"

require_relative "../../../../app/controllers/api/v1/hashtags_controller"

describe HashtagsController do
  def app
    HashtagsController
  end

  it "will return 200 with hashtags data" do
    allow(Hashtag)
      .to receive(:trending)
      .and_return([{
        :name => "backend",
        :count => 21
      }])

    get "/api/v1/hashtags/trending"

    expect(last_response).to be_ok
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq({
      :status => "Success",
      :data => {
        :hashtags => [{
          :name => "backend",
          :count => 21
        }]
      }
    }.to_json)
  end
end
