class User
  def initialize(params)
    @username = params[:username]
    @email = params[:email]
  end

  def validate
    result = {
      :valid => true,
      :errors => []
    }

    if @username.nil? || @username.empty?
      result[:valid] = false
      result[:errors] << "Username can't be nil or empty."
    end

    if !@username.nil? && @username.size > 20
      result[:valid] = false
      result[:errors] << "Username can't be more than 20 characters."
    end

    if @email.nil? || @email.empty?
      result[:valid] = false
      result[:errors] << "Email can't be nil or empty."
    end

    if !@email.nil? && @email.size > 50
      result[:valid] = false
      result[:errors] << "Email can't be more than 50 characters."
    end

    result
  end
end
