require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  test "GET index renders" do
    get examples_tasks_path
    assert_response :success
    assert_match "Open Task Modal", response.body
  end

  test "GET modal_body renders the initial partial without layout" do
    get examples_tasks_modal_body_path
    assert_response :success
    assert_match 'id="task-frame"', response.body
    assert_match "Run Task 1", response.body
    assert_no_match "<html", response.body
  end

  test "POST run with task that has result returns success partial" do
    post examples_tasks_run_path, params: { task_id: 1 }
    assert_response :success
    assert_match 'id="task-frame"', response.body
    assert_match "Task 1 complete", response.body
    assert_match "128", response.body
  end

  test "POST run with task that has no result returns empty partial" do
    post examples_tasks_run_path, params: { task_id: 3 }
    assert_response :success
    assert_match "no result", response.body
  end

  test "POST run with task that raises returns error partial with 422" do
    post examples_tasks_run_path, params: { task_id: 4 }
    assert_response :unprocessable_entity
    assert_match "Service temporarily unavailable", response.body
  end
end
