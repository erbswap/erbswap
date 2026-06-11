require "application_system_test_case"

class ReportsTest < ApplicationSystemTestCase
  test "modal opens and request shows success state" do
    visit examples_reports_path
    assert_selector "h2", text: "Modal + form swap"

    click_button "Open Report Modal"
    click_button "Request 2024 Report"

    assert_text "Report for 2024"
    assert_text "Found 128 rows"
  end

  test "year with no data shows empty state" do
    visit examples_reports_path
    click_button "Open Report Modal"
    click_button "Request 2022 Report"

    assert_text "No data found for 2022"
  end

  test "year that raises shows error state" do
    visit examples_reports_path
    click_button "Open Report Modal"
    click_button "Request 2025 Report"

    assert_text "Service temporarily unavailable"
  end
end
