require_relative "../../app/models/hashtag"

describe Hashtag do
  describe "#validate" do
    context "when hashtagable_id nil" do
      it "will return falsey hash with errors" do
        hashtag = Hashtag.new({
          :hashtagable_id => nil
        })
        validate_result = hashtag.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Hashtagable Id can't be nil or empty.")
      end
    end

    context "when hashtagable_type nil or empty" do
      it "will return falsey hash with errors" do
        hashtag = Hashtag.new({
          :hashtagable_id => 1,
          :hashtagable_type => nil
        })
        validate_result = hashtag.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Hashtagable Type can't be nil or empty.")

        hashtag = Hashtag.new({
          :hashtagable_id => 1,
          :hashtagable_type => ""
        })
        validate_result = hashtag.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Hashtagable Type can't be nil or empty.")
      end
    end

    context "when name nil or empty" do
      it "will return falsey hash with errors" do
        hashtag = Hashtag.new({
          :hashtagable_id => 1,
          :hashtagable_type => "POST",
          :name => nil
        })
        validate_result = hashtag.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Name can't be nil or empty.")

        hashtag = Hashtag.new({
          :hashtagable_id => 1,
          :hashtagable_type => "POST",
          :name => ""
        })
        validate_result = hashtag.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Name can't be nil or empty.")
      end
    end

    context "when name characters more than 255" do
      it "will return falsey hash with errors" do
        hashtag = Hashtag.new({
          :hashtagable_id => 1,
          :hashtagable_type => "POST",
          :name => "backend" * 37
        })
        validate_result = hashtag.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Name can't be more than 255 characters.")
      end
    end
  end

  describe "#save" do
    context "when doesn't pass validation" do
      it "will return falsey hash with errors" do
        hashtag = Hashtag.new({
          :hashtagable_id => nil,
          :hashtagable_type => "",
          :name => ""
        })

        allow(hashtag)
          .to receive(:validate)
          .and_return({
            :valid => false,
            :errors => Array.new(3)
          })

        save_result = hashtag.save
        expect(save_result[:success]).to be_falsey
        expect(save_result[:errors].size).to eq(3)
      end
    end

    context "when passed validation" do
      it "will return truthy hash with generated hashtag data" do
        hashtag = Hashtag.new({
          :hashtagable_id => 1,
          :hashtagable_type => "POST",
          :name => "backend"
        })

        allow(hashtag)
          .to receive(:validate)
          .and_return({
            :valid => true,
            :errors => []
          })

        client = double
        allow(MySQLConnector)
          .to receive(:client)
          .and_return(client)

        expect(client)
          .to receive(:query)
          .with("INSERT INTO hashtags(hashtagable_id, hashtagable_type, name) VALUES(1, 'POST', 'backend');")

        allow(client)
          .to receive(:last_id)
          .and_return(1)

        allow(client)
          .to receive(:query)
          .with("SELECT * FROM hashtags WHERE id = 1;")
          .and_return([{
            "id" => 1,
            "hashtagable_id" => 1,
            "hashtagable_type" => "POST",
            "name" => "backend",
            "created_at" => "2021-08-21 20:08:21"
          }])

        save_result = hashtag.save
        expect(save_result[:success]).to be_truthy
        expect(save_result[:errors].size).to eq(0)
        expect(save_result[:hashtag]).to eq({
          :id => 1,
          :hashtagable_id => 1,
          :hashtagable_type => "POST",
          :name => "backend",
          :created_at => "2021-08-21 20:08:21"
        })
      end
    end
  end

  describe ".trending" do
    context "when there's no trending hashtags in the past 24 hours" do
      it "will return empty array" do
        trending = Hashtag.trending
        expect(trending).to be_empty
      end
    end
  end
end
