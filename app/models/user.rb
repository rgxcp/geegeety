class User
  def initialize(params)
    @username = params[:username]
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

    result
  end
end
