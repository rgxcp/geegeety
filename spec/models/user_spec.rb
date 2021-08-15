require_relative "../../app/models/user"

describe User do
  describe "#validate" do
    context "when username nil or empty" do
      it "will return false with error" do
        user = User.new({
          :username => nil
        })
        validate_result = user.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Username can't be nil or empty.")

        user = User.new({
          :username => ""
        })
        validate_result = user.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Username can't be nil or empty.")
      end
    end

    context "when username characters more than 20" do
      it "will return false with error" do
        user = User.new({
          :username => "johndoe" * 3
        })
        validate_result = user.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Username can't be more than 20 characters.")
      end
    end
  end
end
