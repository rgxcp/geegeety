require_relative "../../app/models/post"

describe Post do
  describe "#validate" do
    let(:file) { double }

    let(:post) {
      Post.new({
        :body => "Hello, World! #gg",
        :attachment => file
      })
    }

    context "when body nil or empty" do
      it "will return falsey hash with errors" do
        post = Post.new({
          :body => nil
        })
        validate_result = post.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Body can't be nil or empty.")

        post = Post.new({
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
          :body => "Hello, World! #gg" * 59
        })
        validate_result = post.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Body can't be more than 1000 characters.")
      end
    end

    context "when attachment size equal to 0B" do
      it "will return falsey hash with errors" do
        allow(file)
          .to receive(:size)
          .and_return(0)

        validate_result = post.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Attachment size can't be equal to 0 Bytes.")
      end
    end

    context "when attachment size more than 5MB" do
      it "will return falsey hash with errors" do
        allow(file)
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
          :body => "Hello, World!"
        })
        hashtags = post.filter_hashtags
        expect(hashtags).to be_empty
      end
    end

    context "when body contain 3 hashtags" do
      it "will return array with 3 hashtags" do
        post = Post.new({
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
          :body => "Hello, World! #backend #ruby #gg #GG"
        })
        hashtags = post.filter_hashtags
        expect(hashtags.size).to eq(3)
        expect(hashtags).to eq(["backend", "ruby", "gg"])
      end
    end
  end
end
