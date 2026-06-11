require "application_system_test_case"

class TasksTest < ApplicationSystemTestCase
  test "modal opens and running a task shows success state" do
    visit examples_tasks_path
    assert_selector "h2", text: "Modal + form swap"

    click_button "Open Task Modal"
    click_button "Run Task 1"

    assert_text "Task 1 complete"
    assert_text "128"
  end

  test "task with no result shows empty state" do
    visit examples_tasks_path
    click_button "Open Task Modal"
    click_button "Run Task 3"

    assert_text "no result"
  end

  test "task that raises shows error state" do
    visit examples_tasks_path
    click_button "Open Task Modal"
    click_button "Run Task 4"

    assert_text "Service temporarily unavailable"
  end
end
