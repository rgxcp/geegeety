require_relative "application_controller"
require_relative "../models/user"

class UsersController < ApplicationController
  post "/api/v1/users" do
    user = User.new(params)
    user = user.save

    status 403
    result = {
      :status => "Failed",
      :errors => user[:errors]
    }
    result.to_json
  end
end
