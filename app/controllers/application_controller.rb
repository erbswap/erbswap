class ApplicationController < ActionController::Base
  include ErbswapRenderable

  allow_browser versions: :modern
end
