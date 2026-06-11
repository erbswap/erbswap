class TasksController < ApplicationController
  TASKS = [ 1, 2, 3, 4 ].freeze
  RESULTS = { 1 => 128, 2 => 94 }.freeze

  def index
  end

  def modal_body
    render_erbswap(
      partial: "tasks/modal_initial",
      locals: { tasks: TASKS }
    )
  end

  def run
    sleep 1.5 unless Rails.env.test?

    task_id = params[:task_id].to_i

    raise StandardError, "Service temporarily unavailable." if task_id == 4

    if (count = RESULTS[task_id])
      render_erbswap(
        partial: "tasks/modal_success",
        locals: { task_id: task_id, item_count: count }
      )
    else
      render_erbswap(
        partial: "tasks/modal_empty",
        locals: { task_id: task_id }
      )
    end
  rescue StandardError => e
    render_erbswap(
      partial: "tasks/modal_error",
      locals: { task_id: task_id, message: e.message },
      status: :unprocessable_entity
    )
  end
end
