require_relative "../models/hashtag"

class Utils
  def self.store_hashtags(params)
    results = []

    params[:hashtags].each do |name|
      hashtag = Hashtag.new({
        :hashtagable_id => params[:hashtagable_id],
        :hashtagable_type => params[:hashtagable_type],
        :name => name
      })
      hashtag = hashtag.save
      results << hashtag[:hashtag] if hashtag[:success]
    end

    results
  end
end
