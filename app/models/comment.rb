class Comment
  def initialize(params)
    @user_id = params[:user_id]
    @post_id = params[:post_id]
    @body = params[:body]
    @attachment = params[:attachment]
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

    if @attachment && @attachment.size == 0
      result[:valid] = false if result[:valid]
      result[:errors] << "Attachment size can't be equal to 0 Bytes."
    end

    if @attachment && @attachment.size > 5242880
      result[:valid] = false if result[:valid]
      result[:errors] << "Attachment size can't be more than 5 Megabytes."
    end

    result
  end
end
