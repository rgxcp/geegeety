require_relative "../api_controller"
require_relative "../../../models/user"

class UsersController < APIController
  post "/api/v1/users" do
    user = User.new(params)
    user = user.save

    if user[:success]
      status 201
      response = {
        :status => "Success",
        :data => {
          :user => user[:user]
        }
      }
    else
      status 403
      response = {
        :status => "Failed",
        :errors => user[:errors]
      }
    end

    response.to_json
  end
end
