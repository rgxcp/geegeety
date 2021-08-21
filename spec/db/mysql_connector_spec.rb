require_relative "../../app/db/mysql_connector"

describe MySQLConnector do
  describe ".client" do
    it "will return client instance" do
      mysql2_client = double
      allow(Mysql2::Client)
        .to receive(:new)
        .and_return(mysql2_client)

      mysql_connector_client = MySQLConnector.client

      expect(mysql_connector_client).to eq(mysql2_client)
    end
  end
end
