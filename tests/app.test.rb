require_relative './test_helper'
require './app/app'

class AppTest < Test::Unit::TestCase
  def app
    Sinatra::Application
  end

  def test_get_should_response_ok
    get '/'
    assert last_response.ok?
  end

  def test_get_svg_should_response_with_content_type
    get '/test.svg'
    assert_equal last_response.header['content-type'], 'image/svg+xml'
    assert last_response.ok?

    get '/test.svg#id'
    assert_equal last_response.header['content-type'], 'image/svg+xml'
    assert last_response.ok?
  end

  def test_get_with_extension_should_response_ok
    get 'test.png'
    assert last_response.ok?

    get '/path/name/test.ttf'
    assert last_response.ok?

    get '/path/test.webmanifest'
    assert last_response.ok?
  end
end
