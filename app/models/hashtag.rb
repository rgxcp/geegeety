class Hashtag
  def initialize(params)
    @hashtagable_id = params[:hashtagable_id]
  end

  def validate
    {
      :valid => false,
      :errors => ["Hashtagable Id can't be nil or empty."]
    }
  end
end
