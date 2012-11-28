require 'sinatra/base'
require 'nokogiri'
require 'open-uri'
require 'json'
unless ENV['RACK_ENV'] == 'production'
  require 'debugger'
end

class NewsDownloader < Sinatra::Base
  
  TopNewsUrl = 'http://feeds.feedburner.com/reuters/topNews/'
  WorldNewsUrl = 'http://feeds.reuters.com/reuters/UKWorldNews/'
  ImageUrl = 'http://pugme.herokuapp.com/random'
  
  get '/top_news' do
    get_articles(TopNewsUrl)
  end
  
  get '/world_news' do
    get_articles(WorldNewsUrl)
  end
  
  get '/' do
    @image = get_image_url
    erb :index
  end
  
private

  def get_articles(url)
    @articles = []
    links = parse_link get_feed(url)
    links.each_with_index do |link, index|
      @articles << parse_article(link, index+1)
    end
    erb :article_list
  end
  
  def get_feed(url)
    Nokogiri::XML URI.parse(url).read
  end
  
  def get_image_url
    JSON.parse(URI.parse(ImageUrl).read)['pug']
  end
  
  def parse_link(feed)
    feed.xpath("//item//link").collect(&:text)
  end
  
  def parse_article(link, index)
    html = Nokogiri::HTML URI.parse(link).read
    title = html.css(".sectionColumns h1").first.text
    @titles ||= []
    @titles << title
    # location = html.css("div#articleInfo .location").first.text
    # authors = html.css("div#articleInfo .byline").first.text
    # published_at = html.css("div#articleInfo .timestamp").first.text
    article_info = html.css("div.articleInfo").to_s
    content = html.css("span#articleText").first.to_s
    "<div class=articleTitle>#{index}. #{title}</div>" + 
    article_info + 
    content
  end
  
end