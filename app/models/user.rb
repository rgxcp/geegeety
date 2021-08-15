require_relative "../db/mysql_connector"

class User
  def initialize(params)
    @username = params[:username]
    @email = params[:email]
    @bio = params[:bio]
  end

  def validate
    result = {
      :valid => true,
      :errors => []
    }

    if @username.nil? || @username.empty?
      result[:valid] = false if result[:valid]
      result[:errors] << "Username can't be nil or empty."
    end

    if !@username.nil? && @username.size > 20
      result[:valid] = false if result[:valid]
      result[:errors] << "Username can't be more than 20 characters."
    end

    if @email.nil? || @email.empty?
      result[:valid] = false if result[:valid]
      result[:errors] << "Email can't be nil or empty."
    end

    if !@email.nil? && @email.size > 50
      result[:valid] = false if result[:valid]
      result[:errors] << "Email can't be more than 50 characters."
    end

    if @bio.nil? || @bio.empty?
      result[:valid] = false if result[:valid]
      result[:errors] << "Bio can't be nil or empty."
    end

    if !@bio.nil? && @bio.size > 200
      result[:valid] = false if result[:valid]
      result[:errors] << "Bio can't be more than 200 characters."
    end

    result
  end

  def exists?
    client = MySQLConnector.client
    row = client.query("SELECT COUNT(1) as count FROM users WHERE username = '#{@username}' OR email = '#{@email}';")
    row = row.first
    return true if row["count"] != 0
    false
  end
end
