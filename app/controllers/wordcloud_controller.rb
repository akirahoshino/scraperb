# require 'rake'
# Rails.application.load_tasks

class WordcloudController < ApplicationController
  def home
    @url = params[:url]
    puts @url
    url_check = @url.split("/")[2]
    file_name = @url.split("/")[-1]
    if url_check == 'www.wantedly.com'
      %x[bundle exec rails wordcloud:save_png[#{@url}]]
    end
    puts "Saved PNG"
    send_file "#{file_name}.png", type: 'image/png', disposition: 'inline'
    # Rake::Task["wordcloud:save_png[#{@url}]"].execute
    # Rake::Task["wordcloud:save_png[#{@url}]"].clear
  end
end
