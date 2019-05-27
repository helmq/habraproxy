require 'sinatra'
require 'nokogiri'
require 'net/http'
require 'open-uri'
require_relative './modifier'

url = 'https://habr.com'

get(/.*\.[^\\]+/) do
  path = request.path
  extension = path.split('/').last.split('.').last
  response.headers['Content-Type'] = 'image/svg+xml' if extension == 'svg'
  uri = URI.join(url, path)
  Net::HTTP.get(uri)
end

get '/*' do
  target_url = request.fullpath ? URI.join(url, request.fullpath) : URI.parse(url)
  html = target_url.read
  Modifier.new(html, url).apply_all_modifiers.to_html
end
