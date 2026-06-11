require "application_system_test_case"

class SignupsTest < ApplicationSystemTestCase
  test "initial availability state shown on page load" do
    visit examples_new_signup_path
    assert_text "Pick a username above and see if it's available"
  end

  test "taken username swaps in taken state" do
    visit examples_new_signup_path
    fill_in "Username", with: "alice"
    click_button "Check availability"

    assert_text "alice is already taken"
  end

  test "available username swaps in available state" do
    visit examples_new_signup_path
    fill_in "Username", with: "newuser"
    click_button "Check availability"

    assert_text "newuser is available"
  end

  test "short username swaps in invalid state" do
    visit examples_new_signup_path
    fill_in "Username", with: "ab"
    click_button "Check availability"

    assert_text "must be at least 3 characters"
  end
end
