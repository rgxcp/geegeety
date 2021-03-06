require_relative "../db/mysql_connector"
require_relative "../utils/utils"

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

  def filter_hashtags
    @body.scan(/#(\w+)/).flatten.map(&:downcase).uniq
  end

  def save
    result = {
      :success => true,
      :errors => []
    }

    validate_result = self.validate
    unless validate_result[:valid]
      result[:success] = false
      result[:errors] = validate_result[:errors]
      return result
    end

    client = MySQLConnector.client
    if @attachment
      filename = Utils.upload_file(@attachment)
      client.query("INSERT INTO comments(user_id, post_id, body, attachment) VALUES(#{@user_id}, #{@post_id}, '#{@body}', '#{filename}');")
    else
      client.query("INSERT INTO comments(user_id, post_id, body) VALUES(#{@user_id}, #{@post_id}, '#{@body}');")
    end
    id = client.last_id
    row = client.query("SELECT * FROM comments WHERE id = #{id};")
    row = row.first
    row["attachment"] = "http://localhost:4567/api/v1/attachments/#{row["attachment"]}" unless row["attachment"].empty?
    result[:comment] = {
      :id => row["id"],
      :user_id => @user_id,
      :post_id => @post_id,
      :body => @body,
      :attachment => row["attachment"],
      :hashtags => [],
      :created_at => row["created_at"]
    }

    hashtags = self.filter_hashtags
    result[:comment][:hashtags] = Utils.store_hashtags({
      :hashtagable_id => result[:comment][:id],
      :hashtagable_type => "COMMENT",
      :hashtags => hashtags
    }) if hashtags.size > 0

    result
  end
end
