require "mysql2"
require "singleton"

class MySQLConnector
  include Singleton
  attr_reader :client

  def initialize
    @client = Mysql2::Client.new(
      :host => ENV["GEEGEETY_HOST"],
      :username => ENV["GEEGEETY_USERNAME"],
      :password => ENV["GEEGEETY_PASSWORD"],
      :database => ENV["GEEGEETY_DATABASE"]
    )
  end

  def self.client
    instance.client
  end
end
