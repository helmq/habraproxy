require 'nokogiri'

class Modifier
  attr_reader :document

  def initialize(html, url)
    @document = Nokogiri::HTML.parse(html, nil, 'utf-8')
    @url = URI(url)
    @hyperlink_tag_attrs = { a: 'href', use: 'xlink:href', form: 'action' }
  end

  def modify_nodes(node = @document.children)
    node.each do |n|
      modify_hyperlink_node(n) if @hyperlink_tag_attrs.key?(n.name.to_sym)
      n.content = modify_string(n.text, 6, '™') if n.text? && n.text.match?(/\p{L}+/)
      modify_nodes(n.children) if n.children
    end
    self
  end

  def to_html
    @document.to_html
  end

  private

  def modify_hyperlink_node(node)
    attribute_name = @hyperlink_tag_attrs[node.name.to_sym]
    attribute = node.attribute(attribute_name)
    return if attribute.nil?

    href = URI.parse(URI.escape(attribute.value))
    return if href.host != @url.host

    new_href = URI.parse(URI.unescape(href.to_s))
    new_href.scheme = nil
    new_href.host = nil
    new_href.port = nil

    node.set_attribute(attribute_name, new_href.to_s)
  end

  def modify_string(str, word_len, appended)
    regex = /\p{L}/
    current_word_len = 0
    fixed_str = str.sub('&plus;', '+')
    str_as_ary = fixed_str.split('')

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
