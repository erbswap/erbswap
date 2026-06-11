require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "GET index renders list" do
    get examples_articles_path
    assert_response :success
    assert_match "Server-driven UI is good, actually", response.body
  end

  test "GET preview returns the article partial without layout" do
    get examples_article_preview_path(1)
    assert_response :success
    assert_match 'id="article-preview-1"', response.body
    assert_match "The original Rails value proposition", response.body
    assert_no_match "<html", response.body
  end

  test "GET preview for unknown id returns 404" do
    get examples_article_preview_path(999)
    assert_response :not_found
  end
end
