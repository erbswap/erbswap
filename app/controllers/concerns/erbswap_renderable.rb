module ErbswapRenderable
  extend ActiveSupport::Concern

  private

  def render_erbswap(partial:, locals: {}, status: :ok)
    render partial: partial, locals: locals, formats: [:html], layout: false, status: status
  end
end
