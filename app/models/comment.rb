class Comment
  def initialize(params)
    @user_id = params[:user_id]
  end

  def validate
    {
      :valid => false,
      :errors => ["User Id can't be nil or empty."]
    }
  end
end
