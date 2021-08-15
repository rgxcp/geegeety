class Post
  def initialize(params)
    @body = params[:body]
  end

  def validate
    result = {
      :valid => true,
      :errors => []
    }

    if @body.nil? || @body.empty?
      result[:valid] = false
      result[:errors] << "Body can't be nil or empty."
    end

    if @body && @body.size > 1000
      result[:valid] = false if result[:valid]
      result[:errors] << "Body can't be more than 1000 characters."
    end

    result
  end
end
