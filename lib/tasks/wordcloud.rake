namespace :wordcloud do
  desc 'create wordcloud'
  task :save_png, ['url'] => :environment do |task, args|
    require 'nokogiri'
    require 'open-uri'
    require 'magic_cloud'
    
    # WantedlyProjectテーブルから'published'かつ'kyoto'のものをピック
    # そのURLについて再度nokogiriでパースしてwordcloud作成
    # material = WantedlyProject.published.where(longitude: 135..136, latitude: 34.8..35.5)
    # url = material.first.url

    # url = 'https://www.wantedly.com/projects/452432'
    url = args.to_s.split(" ")[-1].split('>')[0]
    
    print("url is #{url} \n")
    # Nokogiriでbodyのみ抽出
    doc = Nokogiri::HTML(open(url))
    body = doc.xpath('//*[@id="project-show-body"]/div/div[1]/div/div').text.split

    # 配列を１つの文章にまとめ、ひらがなを削除して、漢字とカタカナのみ取り出す。
    sentence = body.each { |word| word.split(' ') }.join
    words = sentence.tr('ぁ-ん、-。', ' ').split
    # puts words

    # 句読点、「」・！？等の記号も消したい...
    # letters = words.each{ |word| word.delete('、,。,！,’,”,■,「') }
    letters = words.map { |word| word.gsub(/[￣■！-／：-＠［-｀｛-～、-〜”’・]+/, ",") }
    letter = letters.map{ |a| a.split(',') }.flatten
    # letters = words.each{ |word| word.gsub(/[。、「」！＠■◆]/, '') }
    # p letter

    # 一文字だけの要素を排除
    terms = letter.reject { |letter| letter.size < 2 }

    # 配列の要素数でヒストグラムを作成し、頻度が2以上のものだけにし降順にする
    hist = terms.group_by(&:itself).map { |key, value| [key, value.count] }.to_h
    result = hist.select { |_k, v| v > 1 }.sort { |a, b| a[1] <=> b[1] }.reverse
    # p result

    # ワードクラウド作成
    # https://www.wantedly.com/projects/452432
    file_name = url.split("/")[-1]
    font = 'Arial Unicode'
    # cloud = MagicCloud::Cloud.new(result, rotate: :none, palette: :category20, scale: :log, font_family: font )
    cloud = MagicCloud::Cloud.new(result, rotate: :none, palette: :category20, scale: :log, font_family: font )
    cloud.draw(600, 600).write("#{file_name}.png")
    puts "SAVED"
  end

  task delete_png: :environment do  
  end
end
