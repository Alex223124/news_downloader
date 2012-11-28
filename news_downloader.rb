require 'sinatra/base'
require 'nokogiri'
require 'open-uri'
unless ENV['RACK_ENV'] == 'production'
  require 'debugger'
end

class NewsDownloader < Sinatra::Base
  
  TopNewsUrl = 'http://feeds.feedburner.com/reuters/topNews/'
  WorldNewsUrl = 'http://feeds.reuters.com/reuters/UKWorldNews/'
  
  get '/top_news' do
    get_articles(TopNewsUrl)
  end
  
  get '/world_news' do
    get_articles(WorldNewsUrl)
  end
  
private

  def get_articles(url)
    @articles = []
    links = parse_link get_feed(url)
    links.each do |link|
      @articles << parse_article(link)
    end
    erb :article_list
  end
  
  def get_feed(url)
    Nokogiri::XML URI.parse(url).read
  end
  
  def parse_link(feed)
    feed.xpath("//item//link").collect(&:text)
  end
  
  def parse_article(link)
    html = Nokogiri::HTML URI.parse(link).read
    title = html.css("meta[@property='og:title']").first.attributes['content'].to_s
    @titles ||= []
    @titles << title
    # location = html.css("div#articleInfo .location").first.text
    # authors = html.css("div#articleInfo .byline").first.text
    # published_at = html.css("div#articleInfo .timestamp").first.text
    article_info = html.css("div.articleInfo").to_s
    content = html.css("span#articleText").first.to_s
    "<div class='articleTitle'>#{title}</div>" + 
    article_info + 
    content
  end
  
end