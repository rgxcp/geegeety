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

    if @bio.nil? || @bio.empty?
      result[:valid] = false
      result[:errors] << "Bio can't be nil or empty."
    end

    result
  end
end
