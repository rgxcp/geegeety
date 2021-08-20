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

  def self.upload_file(attachment)
    extension = File.extname(attachment[:tempfile])
    filename = Time.now.strftime("%Y%m%d%H%M%S#{extension}")

    file = File.open("public/attachments/#{filename}", "wb")
    file.write(attachment[:tempfile].read)

    filename
  end
end
