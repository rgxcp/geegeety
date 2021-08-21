require_relative "../../app/models/hashtag"

describe Hashtag do
  let(:client) { double }

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
            "created_at" => "2021-08-21 20:08:21 +0700"
          }])

        save_result = hashtag.save
        expect(save_result[:success]).to be_truthy
        expect(save_result[:errors].size).to eq(0)
        expect(save_result[:hashtag]).to eq({
          :id => 1,
          :hashtagable_id => 1,
          :hashtagable_type => "POST",
          :name => "backend",
          :created_at => "2021-08-21 20:08:21 +0700"
        })
      end
    end
  end

  describe ".trending" do
    context "when there's no trending hashtags in the past 24 hours" do
      it "will return empty array" do
        allow(MySQLConnector)
          .to receive(:client)
          .and_return(client)

        allow(DateTime)
          .to receive_message_chain(:now, :prev_day, :strftime)
          .with("%Y-%m-%d %H:%M:%S")
          .and_return("2021-08-21 20:08:21")

        allow(client)
          .to receive(:query)
          .with("SELECT name, COUNT(name) AS count FROM hashtags WHERE created_at >= '2021-08-21 20:08:21' GROUP BY name ORDER BY count DESC LIMIT 5;")
          .and_return([])

        trending = Hashtag.trending
        expect(trending).to be_empty
      end
    end

    context "when there's trending hashtags in the past 24 hours" do
      it "will return array of hash" do
        allow(MySQLConnector)
          .to receive(:client)
          .and_return(client)

        allow(DateTime)
          .to receive_message_chain(:now, :prev_day, :strftime)
          .with("%Y-%m-%d %H:%M:%S")
          .and_return("2021-08-21 20:08:21")

        allow(client)
          .to receive(:query)
          .with("SELECT name, COUNT(name) AS count FROM hashtags WHERE created_at >= '2021-08-21 20:08:21' GROUP BY name ORDER BY count DESC LIMIT 5;")
          .and_return([{
            "name" => "backend",
            "count" => 21
          }])

        trending = Hashtag.trending
        expect(trending).to be_an(Array)
        expect(trending.first).to be_a(Hash)
        expect(trending.first).to eq({
          :name => "backend",
          :count => 21
        })
      end
    end
  end

  describe ".posts(name)" do
    context "when there's no posts for a hashtag" do
      it "will return empty array" do
        allow(MySQLConnector)
          .to receive(:client)
          .and_return(client)

        allow(client)
          .to receive(:query)
          .with("SELECT posts.* FROM hashtags JOIN posts ON hashtags.hashtagable_id = posts.id WHERE name = 'frontend' AND hashtagable_type = 'POST' ORDER BY id DESC;")
          .and_return([])

        hashtag_posts = Hashtag.posts("frontend")
        expect(hashtag_posts).to be_empty
      end
    end

    context "when there's posts for a hashtag" do
      it "will return array of hash" do
        allow(MySQLConnector)
          .to receive(:client)
          .and_return(client)

        allow(client)
          .to receive(:query)
          .with("SELECT posts.* FROM hashtags JOIN posts ON hashtags.hashtagable_id = posts.id WHERE name = 'backend' AND hashtagable_type = 'POST' ORDER BY id DESC;")
          .and_return([{
            "id" => 1,
            "user_id" => 2,
            "body" => "Hello, World!",
            "attachment" => "",
            "created_at" => "2021-08-21 20:08:21 +0700"
          }])

        hashtag_posts = Hashtag.posts("backend")
        expect(hashtag_posts).to be_an(Array)
        expect(hashtag_posts.first).to be_a(Hash)
        expect(hashtag_posts.first).to eq({
          :id => 1,
          :user_id => 2,
          :body => "Hello, World!",
          :attachment => "",
          :created_at => "2021-08-21 20:08:21 +0700"
        })
      end
    end
  end
end
