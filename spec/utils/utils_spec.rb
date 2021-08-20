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
            :created_at => "2021-08-21 20:08:21"
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
        :created_at => "2021-08-21 20:08:21"
      })
    end
  end
end
