require_relative "../../app/models/comment"

describe Comment do
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
  end
end
