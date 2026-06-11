require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  test "GET index renders" do
    get examples_reports_path
    assert_response :success
    assert_match "Open Report Modal", response.body
  end

  test "GET modal_body renders the initial partial without layout" do
    get examples_reports_modal_body_path
    assert_response :success
    assert_match 'id="report-frame"', response.body
    assert_match "Request 2024 Report", response.body
    assert_no_match "<html", response.body
  end

  test "POST submit_year with data returns success partial" do
    post examples_reports_submit_year_path, params: { year: 2024 }
    assert_response :success
    assert_match 'id="report-frame"', response.body
    assert_match "Found 128 rows", response.body
  end

  test "POST submit_year without data returns empty partial" do
    post examples_reports_submit_year_path, params: { year: 2022 }
    assert_response :success
    assert_match "No data found for 2022", response.body
  end

  test "POST submit_year that raises returns error partial with 422" do
    post examples_reports_submit_year_path, params: { year: 2025 }
    assert_response :unprocessable_entity
    assert_match "Service temporarily unavailable", response.body
  end
end
