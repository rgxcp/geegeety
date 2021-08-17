class Hashtag
  def initialize(params)
    @hashtagable_id = params[:hashtagable_id]
    @hashtagable_type = params[:hashtagable_type]
    @name = params[:name]
  end

  def validate
    result = {
      :valid => true,
      :errors => []
    }

    if @hashtagable_id.nil?
      result[:valid] = false
      result[:errors] << "Hashtagable Id can't be nil or empty."
    end

    if @hashtagable_type.nil? || @hashtagable_type.empty?
      result[:valid] = false if result[:valid]
      result[:errors] << "Hashtagable Type can't be nil or empty."
    end

    if @name.nil? || @name.empty?
      result[:valid] = false if result[:valid]
      result[:errors] << "Name can't be nil or empty."
    end

    if @name && @name.size > 255
      result[:valid] = false if result[:valid]
      result[:errors] << "Name can't be more than 255 characters."
    end

    result
  end
end
