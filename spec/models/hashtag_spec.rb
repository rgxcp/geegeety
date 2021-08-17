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
end
