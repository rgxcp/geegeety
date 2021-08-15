require_relative "../../app/models/post"

describe Post do
  describe "#validate" do
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
        file = double

        allow(file)
          .to receive(:size)
          .and_return(0)

        post = Post.new({
          :body => "Hello, World! #gg",
          :attachment => file
        })
        validate_result = post.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Attachment size can't be equal to 0 Bytes.")
      end
    end

    context "when attachment size more than 5MB" do
      it "will return falsey hash with errors" do
        file = double

        allow(file)
          .to receive(:size)
          .and_return(5242881)

        post = Post.new({
          :body => "Hello, World! #gg",
          :attachment => file
        })
        validate_result = post.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Attachment size can't be more than 5 Megabytes.")
      end
    end
  end
end
