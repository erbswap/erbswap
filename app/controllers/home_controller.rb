class HomeController < ApplicationController
  def index
    @step2_code = <<~CODE
      # app/controllers/application_controller.rb
      class ApplicationController < ActionController::Base
        include ErbswapRenderable
      end

      # config/importmap.rb
      pin "erbswap", to: "erbswap.js"

      # app/javascript/application.js
      import "erbswap"
    CODE

    @step3_code = <<~CODE
      # config/routes.rb
      resources :widgets, only: [:index] do
        collection { post :submit }
      end

      # app/controllers/widgets_controller.rb
      class WidgetsController < ApplicationController
        def index; end

        def submit
          render_erbswap(partial: "widgets/widget_success")
        end
      end

      <%# app/views/widgets/index.html.erb %>
      <%= render "widgets/widget_initial" %>

      <%# app/views/widgets/_widget_initial.html.erb %>
      <div id="widget-frame">
        <form action="<%= submit_widgets_path %>" method="post"
              data-erbswap-form="true"
              data-erbswap-target="widget-frame"
              data-erbswap-swap="replace">
          <%= hidden_field_tag :authenticity_token, form_authenticity_token %>
          <button type="submit" data-erbswap-loading-text="Processing...">Submit</button>
        </form>
      </div>

      <%# app/views/widgets/_widget_success.html.erb %>
      <div id="widget-frame">
        <p>It worked.</p>
      </div>
    CODE
  end
end
