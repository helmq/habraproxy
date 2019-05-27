require 'nokogiri'
require 'erb'

class Modifier
  attr_reader :document

  def initialize(html, url = 'https://habr.com', host = 'localhost:3000')
    @document = Nokogiri::HTML.parse(html, nil, 'utf-8')
    @url = URI(url)
    @host = URI(host)
  end

  def apply_all_modifiers
    modify_links_in_document
    modify_text_nodes
    fix_unicode_plus_symbols
  end

  def modify_links_in_document
    tag_attrs = { a: 'href', use: 'xlink:href' }

    @document.search(*tag_attrs.keys).each do |node|
      attribute_name = tag_attrs[node.name.to_sym]
      attribute = node.attribute(attribute_name)
      next if attribute.nil?

      href = URI.parse(URI.escape(attribute.value))
      next unless href.host == @url.host

      new_href = href.path
      # new_href.scheme = nil
      # new_href.host = nil
      # new_href.port = nil

      node.set_attribute(attribute_name, new_href)
    end
    self
  end

  def modify_text_nodes(node = @document.children)
    node.each do |n|
      n.content = modify_string(n.text, 6, '™') if n.text? && n.text.match?(/\p{L}+/)
      modify_text_nodes(n.children) if n.children
    end
    self
  end

  def fix_unicode_plus_symbols
    @document.search('strong.stacked-menu__item-counter').each do |node|
      node.content = node.content.sub('&plus;', '+')
    end
    self
  end

  def to_html
    @document.to_html
  end

  private

  def modify_string(str, word_len, appended)
    regex = /\p{L}/
    current_word_len = 0
    str_as_ary = str.split('')

    new_str_as_ary = str_as_ary.map.with_index do |char, index|
      unless char.match?(regex)
        current_word_len = 0
        next(char)
      end

      current_word_len += 1
      next_char = str_as_ary[index + 1]
      if next_char !~ regex && current_word_len == word_len
        "#{char}#{appended}"
      else
        char
      end
    end

    new_str_as_ary.join('')
  end
end
