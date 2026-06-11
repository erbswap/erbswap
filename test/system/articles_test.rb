require "application_system_test_case"

class ArticlesTest < ApplicationSystemTestCase
  test "article list renders" do
    visit examples_articles_path
    assert_text "Server-driven UI is good, actually"
    assert_text "Don't build a framework"
    assert_text "ERB partials are underrated"
  end

  test "show preview swaps in the article body" do
    visit examples_articles_path

    within "#article-preview-1" do
      click_button "Show preview"
    end

    assert_text "The original Rails value proposition"
  end

  test "each article preview frame is independent" do
    visit examples_articles_path

    within "#article-preview-2" do
      click_button "Show preview"
    end
    assert_text "Every internal abstraction"

    within "#article-preview-1" do
      assert_button "Show preview"
    end
  end
end
