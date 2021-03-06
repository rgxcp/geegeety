require_relative "../../app/models/comment"

describe Comment do
  let(:attachment) { double }

  let(:comment) {
    Comment.new({
      :user_id => 2,
      :post_id => 1,
      :body => "Hello too, World! #gg",
      :attachment => attachment
    })
  }

  describe "#validate" do
    context "when user_id nil" do
      it "will return falsey hash with errors" do
        comment = Comment.new({
          :user_id => nil
        })
        validate_result = comment.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("User Id can't be nil or empty.")
      end
    end

    context "when post_id nil" do
      it "will return falsey hash with errors" do
        comment = Comment.new({
          :user_id => 2,
          :post_id => nil
        })
        validate_result = comment.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Post Id can't be nil or empty.")
      end
    end

    context "when body nil or empty" do
      it "will return falsey hash with errors" do
        comment = Comment.new({
          :user_id => 2,
          :post_id => 1,
          :body => nil
        })
        validate_result = comment.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Body can't be nil or empty.")

        comment = Comment.new({
          :user_id => 2,
          :post_id => 1,
          :body => ""
        })
        validate_result = comment.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Body can't be nil or empty.")
      end
    end

    context "when body characters more than 1000" do
      it "will return falsey hash with errors" do
        comment = Comment.new({
          :user_id => 2,
          :post_id => 1,
          :body => "Hello too, World! #gg" * 48
        })
        validate_result = comment.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Body can't be more than 1000 characters.")
      end
    end

    context "when attachment size equal to 0B" do
      it "will return falsey hash with errors" do
        allow(attachment)
          .to receive(:size)
          .and_return(0)

        validate_result = comment.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Attachment size can't be equal to 0 Bytes.")
      end
    end

    context "when attachment size more than 5MB" do
      it "will return falsey hash with errors" do
        allow(attachment)
          .to receive(:size)
          .and_return(5242881)

        validate_result = comment.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Attachment size can't be more than 5 Megabytes.")
      end
    end
  end

  describe "#filter_hashtags" do
    context "when body doesn't contain hashtags" do
      it "will return empty array" do
        comment = Comment.new({
          :user_id => 2,
          :post_id => 1,
          :body => "Hello too, World!"
        })
        hashtags = comment.filter_hashtags
        expect(hashtags).to be_empty
      end
    end

    context "when body contain 3 hashtags" do
      it "will return array with 3 hashtags" do
        comment = Comment.new({
          :user_id => 2,
          :post_id => 1,
          :body => "Hello too, World! #backend #ruby #gg"
        })
        hashtags = comment.filter_hashtags
        expect(hashtags.size).to eq(3)
        expect(hashtags).to eq(["backend", "ruby", "gg"])
      end
    end

    context "when body contain 4 hashtags with 3 unique one" do
      it "will return array with 3 uniq hashtags" do
        comment = Comment.new({
          :user_id => 2,
          :post_id => 1,
          :body => "Hello too, World! #backend #ruby #gg #gg"
        })
        hashtags = comment.filter_hashtags
        expect(hashtags.size).to eq(3)
        expect(hashtags).to eq(["backend", "ruby", "gg"])
      end
    end

    context "when body contain 4 hashtags with 3 unique case-insensitive one" do
      it "will return array with 3 uniq case-insensitive hashtags" do
        comment = Comment.new({
          :user_id => 2,
          :post_id => 1,
          :body => "Hello too, World! #backend #ruby #gg #GG"
        })
        hashtags = comment.filter_hashtags
        expect(hashtags.size).to eq(3)
        expect(hashtags).to eq(["backend", "ruby", "gg"])
      end
    end
  end

  describe "#save" do
    let(:client) { double }

    context "when doesn't pass validation" do
      it "will return falsey hash with errors" do
        comment = Comment.new({
          :user_id => nil,
          :post_id => nil,
          :body => ""
        })

        allow(comment)
          .to receive(:validate)
          .and_return({
            :valid => false,
            :errors => Array.new(3)
          })

        save_result = comment.save
        expect(save_result[:success]).to be_falsey
        expect(save_result[:errors].size).to eq(3)
      end
    end

    context "when passed validation and without attachment & hashtags" do
      it "will return truthy hash with generated comment data" do
        comment = Comment.new({
          :user_id => 2,
          :post_id => 1,
          :body => "Hello too, World!"
        })

        allow(comment)
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
          .with("INSERT INTO comments(user_id, post_id, body) VALUES(2, 1, 'Hello too, World!');")

        allow(client)
          .to receive(:last_id)
          .and_return(1)

        allow(client)
          .to receive(:query)
          .with("SELECT * FROM comments WHERE id = 1;")
          .and_return([{
            "id" => 1,
            "user_id" => 2,
            "post_id" => 1,
            "body" => "Hello too, World!",
            "attachment" => "",
            "hashtags" => [],
            "created_at" => "2021-08-21 20:08:21 +0700"
          }])

        allow(comment)
          .to receive(:filter_hashtags)
          .and_return([])

        save_result = comment.save
        expect(save_result[:success]).to be_truthy
        expect(save_result[:errors].size).to eq(0)
        expect(save_result[:comment]).to eq({
          :id => 1,
          :user_id => 2,
          :post_id => 1,
          :body => "Hello too, World!",
          :attachment => "",
          :hashtags => [],
          :created_at => "2021-08-21 20:08:21 +0700"
        })
      end
    end

    context "when passed validation and with attachment & hashtags" do
      it "will return truthy hash with generated comment data with attachment and hashtags" do
        attachment = double
        comment = Comment.new({
          :user_id => 2,
          :post_id => 1,
          :body => "Hello too, World! #backend",
          :attachment => attachment
        })

        allow(comment)
          .to receive(:validate)
          .and_return({
            :valid => true,
            :errors => []
          })

        allow(MySQLConnector)
          .to receive(:client)
          .and_return(client)

        allow(Utils)
          .to receive(:upload_file)
          .and_return("20210821200821.jpg")

        expect(client)
          .to receive(:query)
          .with("INSERT INTO comments(user_id, post_id, body, attachment) VALUES(2, 1, 'Hello too, World! #backend', '20210821200821.jpg');")

        allow(client)
          .to receive(:last_id)
          .and_return(1)

        allow(client)
          .to receive(:query)
          .with("SELECT * FROM comments WHERE id = 1;")
          .and_return([{
            "id" => 1,
            "user_id" => 2,
            "post_id" => 1,
            "body" => "Hello too, World! #backend",
            "attachment" => "20210821200821.jpg",
            "hashtags" => [],
            "created_at" => "2021-08-21 20:08:21 +0700"
          }])

        allow(comment)
          .to receive(:filter_hashtags)
          .and_return(["backend"])

        allow(Utils)
          .to receive(:store_hashtags)
          .and_return([{
            :id => 1,
            :hashtagable_id => 1,
            :hashtagable_type => "COMMENT",
            :name => "backend",
            :created_at => "2021-08-21 20:08:21 +0700"
          }])

        save_result = comment.save
        expect(save_result[:success]).to be_truthy
        expect(save_result[:errors].size).to eq(0)
        expect(save_result[:comment]).to eq({
          :id => 1,
          :user_id => 2,
          :post_id => 1,
          :body => "Hello too, World! #backend",
          :attachment => "http://localhost:4567/api/v1/attachments/20210821200821.jpg",
          :hashtags => [{
            :id => 1,
            :hashtagable_id => 1,
            :hashtagable_type => "COMMENT",
            :name => "backend",
            :created_at => "2021-08-21 20:08:21 +0700"
          }],
          :created_at => "2021-08-21 20:08:21 +0700"
        })
      end
    end
  end
end
