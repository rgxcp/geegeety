require_relative "../../app/models/user"

describe User do
  let(:client) { double }

  let(:exists_user) {
    User.new({
      :username => "janedoe",
      :email => "janedoe@gmail.com",
      :bio => "Frontend Student"
    })
  }

  let(:available_user) {
    User.new({
      :username => "johndoe",
      :email => "johndoe@gmail.com",
      :bio => "Backend Student"
    })
  }

  describe "#validate" do
    context "when username nil or empty" do
      it "will return falsey hash with errors" do
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
      it "will return falsey hash with errors" do
        user = User.new({
          :username => "johndoe" * 3
        })
        validate_result = user.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Username can't be more than 20 characters.")
      end
    end

    context "when email nil or empty" do
      it "will return falsey hash with errors" do
        user = User.new({
          :username => "johndoe",
          :email => nil
        })
        validate_result = user.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Email can't be nil or empty.")

        user = User.new({
          :username => "johndoe",
          :email => ""
        })
        validate_result = user.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Email can't be nil or empty.")
      end
    end

    context "when email characters more than 50" do
      it "will return falsey hash with errors" do
        user = User.new({
          :username => "johndoe",
          :email => "johndoe@gmail.com" * 3
        })
        validate_result = user.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Email can't be more than 50 characters.")
      end
    end

    context "when bio nil or empty" do
      it "will return falsey hash with errors" do
        user = User.new({
          :username => "johndoe",
          :email => "johndoe@gmail.com",
          :bio => nil
        })
        validate_result = user.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Bio can't be nil or empty.")

        user = User.new({
          :username => "johndoe",
          :email => "johndoe@gmail.com",
          :bio => ""
        })
        validate_result = user.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Bio can't be nil or empty.")
      end
    end

    context "when bio characters more than 200" do
      it "will return falsey hash with errors" do
        user = User.new({
          :username => "johndoe",
          :email => "johndoe@gmail.com",
          :bio => "Backend Student" * 14
        })
        validate_result = user.validate
        expect(validate_result[:valid]).to be_falsey
        expect(validate_result[:errors].first).to eq("Bio can't be more than 200 characters.")
      end
    end
  end

  describe "#exists?" do
    context "when username and/or email already used" do
      it "will return truthy value" do
        allow(MySQLConnector)
          .to receive(:client)
          .and_return(client)

        allow(client)
          .to receive(:query)
          .with("SELECT COUNT(1) as count FROM users WHERE username = 'janedoe' OR email = 'janedoe@gmail.com';")
          .and_return([{
            "count" => 1
          }])

        expect(exists_user.exists?).to be_truthy
      end
    end

    context "when username and email isn't used" do
      it "will return falsey value" do
        allow(MySQLConnector)
          .to receive(:client)
          .and_return(client)

        allow(client)
          .to receive(:query)
          .with("SELECT COUNT(1) as count FROM users WHERE username = 'johndoe' OR email = 'johndoe@gmail.com';")
          .and_return([{
            "count" => 0
          }])

        expect(available_user.exists?).to be_falsey
      end
    end
  end

  describe "#save" do
    context "when doesn't pass validation" do
      it "will return falsey hash with errors" do
        user = User.new({
          :username => "",
          :email => "",
          :bio => ""
        })

        expect(user)
          .to receive(:validate)
          .and_return({
            :valid => false,
            :errors => Array.new(3)
          })

        expect(user).not_to receive(:exists?)

        expect(MySQLConnector).not_to receive(:client)

        save_result = user.save
        expect(save_result[:success]).to be_falsey
        expect(save_result[:errors].size).to eq(3)
      end
    end

    context "when username and/or email already used" do
      it "will return falsey hash with errors" do
        expect(exists_user)
          .to receive(:validate)
          .and_return({
            :valid => true,
            :errors => []
          })

        expect(exists_user)
          .to receive(:exists?)
          .and_return(true)

        expect(MySQLConnector).not_to receive(:client)

        save_result = exists_user.save
        expect(save_result[:success]).to be_falsey
        expect(save_result[:errors].first).to eq("Username and/or email already used.")
      end
    end

    context "when passed validation and username & email isn't used" do
      it "will return truthy hash with generated user data" do
        expect(available_user)
          .to receive(:validate)
          .and_return({
            :valid => true,
            :errors => []
          })

        expect(available_user)
          .to receive(:exists?)
          .and_return(false)

        allow(MySQLConnector)
          .to receive(:client)
          .and_return(client)

        expect(client)
          .to receive(:query)
          .with("INSERT INTO users(username, email, bio) VALUES('johndoe', 'johndoe@gmail.com', 'Backend Student');")

        allow(client)
          .to receive(:last_id)
          .and_return(2)

        allow(client)
          .to receive(:query)
          .with("SELECT * FROM users WHERE id = 2;")
          .and_return([{
            "id" => 2,
            "username" => "johndoe",
            "email" => "johndoe@gmail.com",
            "bio" => "Backend Student",
            "created_at" => "2021-20-21 20:21:20"
          }])

        save_result = available_user.save
        expect(save_result[:success]).to be_truthy
        expect(save_result[:errors].size).to eq(0)
        expect(save_result[:user]).to eq({
          :id => 2,
          :username => "johndoe",
          :email => "johndoe@gmail.com",
          :bio => "Backend Student",
          :created_at => "2021-20-21 20:21:20"
        })
      end
    end
  end
end
