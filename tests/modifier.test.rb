require_relative './test_helper'
require './app/modifier'
require 'nokogiri'

class ModifierTest < Test::Unit::TestCase
  def test_modifier
    html_page = open('./tests/fixtures/page.html', &:read)
    html_result = open('./tests/fixtures/result.html', &:read)
    result = Nokogiri::HTML(html_result, nil, 'utf-8').to_html
    modified = Modifier.new(html_page, 'https://habr.com').apply_all_modifiers.to_html

    assert_match result, modified
  end
end
