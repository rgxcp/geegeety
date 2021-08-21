require_relative "../../app/utils/utils"

describe Utils do
  describe ".store_hashtags(params)" do
    it "will return array of hash" do
      hashtag = double
      allow(Hashtag)
        .to receive(:new)
        .and_return(hashtag)

      allow(hashtag)
        .to receive(:save)
        .and_return({
          :success => true,
          :errors => [],
          :hashtag => {
            :id => 1,
            :hashtagable_id => 1,
            :hashtagable_type => "POST",
            :name => "backend",
            :created_at => "2021-08-21 20:08:21 +0700"
          }
        })

      stored_hashtags = Utils.store_hashtags({
        :hashtagable_id => 1,
        :hashtagable_type => "POST",
        :hashtags => ["backend"]
      })

      expect(stored_hashtags).to be_an(Array)
      expect(stored_hashtags.first).to be_a(Hash)
      expect(stored_hashtags.first).to eq({
        :id => 1,
        :hashtagable_id => 1,
        :hashtagable_type => "POST",
        :name => "backend",
        :created_at => "2021-08-21 20:08:21 +0700"
      })
    end
  end

  describe ".upload_file(attachment)" do
    it "will return filename" do
      allow(File)
        .to receive(:extname)
        .and_return(".jpg")

      allow(Time)
        .to receive_message_chain(:now, :strftime)
        .and_return("20210821200821.jpg")

      file = double
      allow(File)
        .to receive(:open)
        .and_return(file)

      attachment = {
        :tempfile => double
      }
      expect(attachment[:tempfile]).to receive(:read)

      expect(file).to receive(:write)

      uploaded_file = Utils.upload_file(attachment)

      expect(uploaded_file).to eq("20210821200821.jpg")
    end
  end
end
