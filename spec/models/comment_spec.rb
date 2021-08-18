require_relative "../../app/models/comment"

describe Comment do
  describe "#validate" do
    let(:file) { double }

    let(:comment) {
      Comment.new({
        :user_id => 2,
        :post_id => 1,
        :body => "Hello too, World! #gg",
        :attachment => file
      })
    }

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
        allow(file)
          .to receive(:size)
          .and_return(0)

        validate_result = comment.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Attachment size can't be equal to 0 Bytes.")
      end
    end

    context "when attachment size more than 5MB" do
      it "will return falsey hash with errors" do
        allow(file)
          .to receive(:size)
          .and_return(5242881)

        validate_result = comment.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Attachment size can't be more than 5 Megabytes.")
      end
    end
  end
end
