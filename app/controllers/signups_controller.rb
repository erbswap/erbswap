class SignupsController < ApplicationController
  TAKEN_USERNAMES = %w[admin alice bob charlie].freeze

  def new
  end

  def check_username
    username = params[:username].to_s.strip

    if username.empty?
      render_erbswap(partial: "signups/availability_initial")
    elsif username.length < 3
      render_erbswap(
        partial: "signups/availability_invalid",
        locals: { username: username },
        status: :unprocessable_entity
      )
    elsif TAKEN_USERNAMES.include?(username.downcase)
      render_erbswap(
        partial: "signups/availability_taken",
        locals: { username: username },
        status: :unprocessable_entity
      )
    else
      render_erbswap(
        partial: "signups/availability_available",
        locals: { username: username }
      )
    end
  end

  def create
    redirect_to examples_new_signup_path,
                notice: "Demo only — no actual signup was created."
  end
end
