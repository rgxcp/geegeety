require "date"
require_relative "../db/mysql_connector"

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
    client.query("INSERT INTO hashtags(hashtagable_id, hashtagable_type, name) VALUES(#{@hashtagable_id}, '#{@hashtagable_type}', '#{@name}');")
    id = client.last_id
    row = client.query("SELECT * FROM hashtags WHERE id = #{id};")
    row = row.first
    result[:hashtag] = {
      :id => row["id"],
      :hashtagable_id => @hashtagable_id,
      :hashtagable_type => @hashtagable_type,
      :name => @name,
      :created_at => row["created_at"]
    }

    result
  end

  def self.trending
    results = []

    client = MySQLConnector.client
    prev_day = DateTime.now.prev_day.strftime("%Y-%m-%d %H:%M:%S")
    rows = client.query("SELECT name, COUNT(name) AS count FROM hashtags WHERE created_at >= '#{prev_day}' GROUP BY name ORDER BY count DESC LIMIT 5;")
    if rows.size > 0
      rows.each do |row|
        hashtag = {
          :name => row["name"],
          :count => row["count"]
        }
        results << hashtag
      end
    end

    results
  end

  def self.posts(name)
    results = []

    client = MySQLConnector.client
    rows = client.query("SELECT posts.* FROM hashtags JOIN posts ON hashtags.hashtagable_id = posts.id WHERE name = '#{name}' AND hashtagable_type = 'POST' ORDER BY id DESC;")
    if rows.size > 0
      rows.each do |row|
        post = {
          :id => row["id"],
          :user_id => row["user_id"],
          :body => row["body"],
          :attachment => row["attachment"],
          :created_at => row["created_at"]
        }
        results << post
      end
    end

    results
  end
end
