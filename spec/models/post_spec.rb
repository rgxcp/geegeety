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
  end
end
