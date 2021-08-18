class Comment
  def initialize(params)
    @user_id = params[:user_id]
    @post_id = params[:post_id]
    @body = params[:body]
  end

  def validate
    result = {
      :valid => true,
      :errors => []
    }

    if @user_id.nil?
      result[:valid] = false
      result[:errors] << "User Id can't be nil or empty."
    end

    if @post_id.nil?
      result[:valid] = false if result[:valid]
      result[:errors] << "Post Id can't be nil or empty."
    end

    if @body.nil? || @body.empty?
      result[:valid] = false if result[:valid]
      result[:errors] << "Body can't be nil or empty."
    end

    if @body && @body.size > 1000
      result[:valid] = false if result[:valid]
      result[:errors] << "Body can't be more than 1000 characters."
    end

    result
  end
end
