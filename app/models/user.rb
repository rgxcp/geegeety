class User
  def initialize(params)
    @username = params[:username]
  end

  def validate
    {
      :valid => false,
      :errors => ["Username can't be nil or empty."]
    }
  end
end
