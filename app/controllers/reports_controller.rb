class ReportsController < ApplicationController
  YEARS = [2025, 2024, 2023, 2022].freeze
  DATA = { 2024 => 128, 2023 => 94 }.freeze

  def index
  end

  def modal_body
    render_erbswap(
      partial: "reports/modal_initial",
      locals: { years: YEARS }
    )
  end

  def submit_year
    year = params[:year].to_i

    raise StandardError, "Service temporarily unavailable for #{year}." if year == 2025

    if (rows = DATA[year])
      render_erbswap(
        partial: "reports/modal_success",
        locals: { year: year, row_count: rows }
      )
    else
      render_erbswap(
        partial: "reports/modal_empty",
        locals: { year: year }
      )
    end
  rescue StandardError => e
    render_erbswap(
      partial: "reports/modal_error",
      locals: { message: e.message },
      status: :unprocessable_entity
    )
  end
end
