class Post
  def initialize(params)
    @body = params[:body]
  end

  def validate
    {
      :valid => false,
      :errors => ["Body can't be nil or empty."]
    }
  end
end
