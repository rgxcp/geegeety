require "sinatra/base"

class AttachmentsController < Sinatra::Base
  get "/api/v1/attachments/:attachment" do
    send_file "public/attachments/#{params[:attachment]}"
  end
end
