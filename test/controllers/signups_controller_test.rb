require "test_helper"

class SignupsControllerTest < ActionDispatch::IntegrationTest
  test "GET new renders" do
    get examples_new_signup_path
    assert_response :success
    assert_match "Username", response.body
  end

  test "check_username with taken name returns 422 + taken partial" do
    get examples_check_username_signup_path, params: { username: "alice" }
    assert_response :unprocessable_entity
    assert_match "alice", response.body
    assert_match "already taken", response.body
  end

  test "check_username with available name returns 200 + available partial" do
    get examples_check_username_signup_path, params: { username: "uniquename" }
    assert_response :success
    assert_match "uniquename", response.body
    assert_match "is available", response.body
  end

  test "check_username with short name returns 422 + invalid partial" do
    get examples_check_username_signup_path, params: { username: "ab" }
    assert_response :unprocessable_entity
    assert_match "at least 3 characters", response.body
  end

  test "check_username with empty input returns initial partial" do
    get examples_check_username_signup_path, params: { username: "" }
    assert_response :success
    assert_match "Pick a username", response.body
  end
end
