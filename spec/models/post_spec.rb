require_relative "../../app/models/post"

describe Post do
  let(:attachment) { double }

  let(:post) {
    Post.new({
      :user_id => 2,
      :body => "Hello, World! #gg",
      :attachment => attachment
    })
  }

  describe "#validate" do
    context "when user_id nil" do
      it "will return falsey hash with errors" do
        post = Post.new({
          :user_id => nil
        })
        validate_result = post.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("User Id can't be nil or empty.")
      end
    end

    context "when body nil or empty" do
      it "will return falsey hash with errors" do
        post = Post.new({
          :user_id => 2,
          :body => nil
        })
        validate_result = post.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Body can't be nil or empty.")

        post = Post.new({
          :user_id => 2,
          :body => ""
        })
        validate_result = post.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Body can't be nil or empty.")
      end
    end

    context "when body characters more than 1000" do
      it "will return falsey hash with errors" do
        post = Post.new({
          :user_id => 2,
          :body => "Hello, World! #gg" * 59
        })
        validate_result = post.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Body can't be more than 1000 characters.")
      end
    end

    context "when attachment size equal to 0B" do
      it "will return falsey hash with errors" do
        allow(attachment)
          .to receive(:size)
          .and_return(0)

        validate_result = post.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Attachment size can't be equal to 0 Bytes.")
      end
    end

    context "when attachment size more than 5MB" do
      it "will return falsey hash with errors" do
        allow(attachment)
          .to receive(:size)
          .and_return(5242881)

        validate_result = post.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Attachment size can't be more than 5 Megabytes.")
      end
    end
  end

  describe "#filter_hashtags" do
    context "when body doesn't contain hashtags" do
      it "will return empty array" do
        post = Post.new({
          :user_id => 2,
          :body => "Hello, World!"
        })
        hashtags = post.filter_hashtags
        expect(hashtags).to be_empty
      end
    end

    context "when body contain 3 hashtags" do
      it "will return array with 3 hashtags" do
        post = Post.new({
          :user_id => 2,
          :body => "Hello, World! #backend #ruby #gg"
        })
        hashtags = post.filter_hashtags
        expect(hashtags.size).to eq(3)
        expect(hashtags).to eq(["backend", "ruby", "gg"])
      end
    end

    context "when body contain 4 hashtags with 3 unique one" do
      it "will return array with 3 uniq hashtags" do
        post = Post.new({
          :user_id => 2,
          :body => "Hello, World! #backend #ruby #gg #gg"
        })
        hashtags = post.filter_hashtags
        expect(hashtags.size).to eq(3)
        expect(hashtags).to eq(["backend", "ruby", "gg"])
      end
    end

    context "when body contain 4 hashtags with 3 unique case-insensitive one" do
      it "will return array with 3 uniq case-insensitive hashtags" do
        post = Post.new({
          :user_id => 2,
          :body => "Hello, World! #backend #ruby #gg #GG"
        })
        hashtags = post.filter_hashtags
        expect(hashtags.size).to eq(3)
        expect(hashtags).to eq(["backend", "ruby", "gg"])
      end
    end
  end

  describe "#save" do
    let(:client) { double }

    context "when doesn't pass validation" do
      it "will return falsey hash with errors" do
        post = Post.new({
          :user_id => nil,
          :body => ""
        })

        allow(post)
          .to receive(:validate)
          .and_return({
            :valid => false,
            :errors => Array.new(2)
          })

        save_result = post.save
        expect(save_result[:success]).to be_falsey
        expect(save_result[:errors].size).to eq(2)
      end
    end

    context "when passed validation and without attachment & hashtags" do
      it "will return truthy hash with generated post data" do
        post = Post.new({
          :user_id => 2,
          :body => "Hello, World!"
        })

        allow(post)
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
          .with("INSERT INTO posts(user_id, body) VALUES(2, 'Hello, World!');")

        allow(client)
          .to receive(:last_id)
          .and_return(1)

        allow(client)
          .to receive(:query)
          .with("SELECT * FROM posts WHERE id = 1;")
          .and_return([{
            "id" => 1,
            "user_id" => 2,
            "body" => "Hello, World!",
            "attachment" => "",
            "hashtags" => [],
            "created_at" => "2021-08-21 20:08:21"
          }])

        allow(post)
          .to receive(:filter_hashtags)
          .and_return([])

        save_result = post.save
        expect(save_result[:success]).to be_truthy
        expect(save_result[:errors].size).to eq(0)
        expect(save_result[:post]).to eq({
          :id => 1,
          :user_id => 2,
          :body => "Hello, World!",
          :attachment => "",
          :hashtags => [],
          :created_at => "2021-08-21 20:08:21"
        })
      end
    end

    context "when passed validation and with attachment & hashtags" do
      it "will return truthy hash with generated post data with attachment and hashtags" do
        attachment = double
        post = Post.new({
          :user_id => 2,
          :body => "Hello, World! #backend",
          :attachment => attachment
        })

        allow(post)
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
          .with("INSERT INTO posts(user_id, body, attachment) VALUES(2, 'Hello, World! #backend', '20210821200821.jpg');")

        allow(client)
          .to receive(:last_id)
          .and_return(1)

        allow(client)
          .to receive(:query)
          .with("SELECT * FROM posts WHERE id = 1;")
          .and_return([{
            "id" => 1,
            "user_id" => 2,
            "body" => "Hello, World! #backend",
            "attachment" => "20210821200821.jpg",
            "hashtags" => [],
            "created_at" => "2021-08-21 20:08:21"
          }])

        allow(post)
          .to receive(:filter_hashtags)
          .and_return(["backend"])

        allow(Utils)
          .to receive(:store_hashtags)
          .and_return([{
            :id => 1,
            :hashtagable_id => 1,
            :hashtagable_type => "POST",
            :name => "backend",
            :created_at => "2021-08-21 20:08:21"
          }])

        save_result = post.save
        expect(save_result[:success]).to be_truthy
        expect(save_result[:errors].size).to eq(0)
        expect(save_result[:post]).to eq({
          :id => 1,
          :user_id => 2,
          :body => "Hello, World! #backend",
          :attachment => "20210821200821.jpg",
          :hashtags => [{
            :id => 1,
            :hashtagable_id => 1,
            :hashtagable_type => "POST",
            :name => "backend",
            :created_at => "2021-08-21 20:08:21"
          }],
          :created_at => "2021-08-21 20:08:21"
        })
      end
    end
  end
end
