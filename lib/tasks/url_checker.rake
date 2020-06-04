namespace :url_checker do
  desc 'Check each wantedly page url then get data into db'
  task url_checker: :environment do
    # 実行したい処理
    require 'nokogiri'
    require 'open-uri'

    

    how_many = 100 # 探索件数

    # how_many で指定した分のurlリストを作成
    base_url = 'https://www.wantedly.com/projects/'
    article_num = '461200'
    # article_num ~ (article_num + how_many) までの数値のリストを作成
    newer_article_nums = (1..how_many).to_a.map { |i| i + article_num.to_i }
    # base_url と newer_article_nums をあわせてURLのリストを作成
    url_list = newer_article_nums.map { |i| base_url + i.to_s }

    # ここでは地域の指定をせずに求人の記事を集める
    url_list.each do |url|
      new_record = WantedlyProject.new
      # rescue で 404エラーを排除
      begin
        doc = Nokogiri::HTML(open(url))
        # 求人であるか判定。除外するのは「ミートアップ」、「企業紹介ページ」
        # HTML title　に'求人'の文字が含まれるか
        if doc.xpath('/html/head/title').text.include?('求人')
          status = 1
          # pp url
          company_name = doc.xpath('//*[@id="project-show-header"]/div[1]/hgroup/h2/a').text.split[0]
          article_date = doc.at_css('[class="header-tags-right"]').text.split[1]
          project_title = doc.xpath('//*[@id="project-show-header"]/div[1]/hgroup/h1').text.split[0]
          # body = doc.at_css('[id="project-show-body"]').text.split

          # 企業情報の記載があるか。住所を書いていない企業は住所と座標の出力を飛ばす
          # GoogleMapを設定していない記事では、xyの取得を飛ばす
          # doc.at_css('[class="company-info-list"]').text.split('/')[-1].split("\n")[-1] => 住所そのまま
          unless doc.at_css('[class="company-info-list"]').text.split('/')[-1].split("\n")[-1].nil?
            company_info = doc.at_css('[class="company-info-list"]').text.split
            company_address = doc.at_css('[class="company-info-list"]').text.split('/')[-1].split("\n")[-1]
            unless doc.at_css('[class="map_container"]').nil?
              company_map = doc.at_css('[class="map_container"]').values
              # xy = [緯度(latitude), 経度(longitude)]
              # 京都　35.0 N, 135.7 E
              xy = company_map[1].split('center=')[1].split('&zoom')[0].split(',')
              latitude, longitude = xy
            end
          end
        else
          # 求人ではなかったら飛ばす
          next
        end

        
      rescue OpenURI::HTTPError => e
        if e.message == '404 Not Found'
          status = 0
          # puts '記事が見つかりませんでした'
        else
          raise e
          puts 'raise e'
        end
      end
      # WantedlyProjectに保存
      new_record.url              = url
      new_record.title            = project_title
      new_record.status           = status
      new_record.posted_at        = article_date
      new_record.company_name     = company_name
      new_record.company_info     = company_info
      new_record.company_address  = company_address
      new_record.latitude         = latitude
      new_record.longitude        = longitude
      # new_record.body             = body
      new_record.save
    end
  end
end
