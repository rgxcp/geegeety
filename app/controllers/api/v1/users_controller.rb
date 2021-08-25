require_relative "../api_controller"
require_relative "../../../models/user"

class UsersController < APIController
  post "/api/v1/users" do
    user = User.new(params)
    user = user.save

    if user[:success]
      status 201
      result = {
        :status => "Success",
        :data => {
          :user => user[:user]
        }
      }
    else
      status 403
      result = {
        :status => "Failed",
        :errors => user[:errors]
      }
    end

    result.to_json
  end
end
