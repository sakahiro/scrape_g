require "imgkit"
require "wkhtmltoimage-binary"
require "mechanize"
require "pry"
require "csv"

IMGKit.configure do |config|
   config.default_options = {
     encoding: "UTF-8"
   }
  config.default_format = :jpg
end

keyword = "your word"

mechanize_agent = Mechanize.new do |agent|
  agent.user_agent_alias = "Mac Safari"
end

mechanize_agent.get("http://google.com/") do |page|
  search_result = page.form_with(id: "tsf") do |search|
    search.q = keyword
  end.submit

  result_array = search_result.search("//li[@class='ads-ad']").map do |ads|
    ad_cclk = ads.search(".//div[@class='ad_cclk']").search(".//a")[1]
    ad_title = ad_cclk.text
    ad_href = ad_cclk.attr("href")
    ad_discription = ads.search(".//div[@class='ellip']").map(&:text).join("\n")
    [ad_title, ad_href, ad_discription]
  end

  File.open("search_result.csv", "w", encoding: "SJIS", undef: :replace, replace: '*') do |file|
    csv = CSV.new(file, encoding: "SJIS")
    csv << [keyword]
    csv << ["タイトル", "url", "description"]
    result_array.each do |result|
      csv << result
    end
    csv.close
  end

  IMGKit.new(search_result.body).to_file("#{keyword}.jpg")
end
