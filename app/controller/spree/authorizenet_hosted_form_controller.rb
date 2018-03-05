module Spree
  class AuthorizenetHostedFormController < Spree::BaseController
    layout false

    before_action :check_customer_id, only: :add_payment

    after_action :change_xframe_opts

    def iframe
    end

    def add_payment
      customer_id = session[:authorizenet_customer_id]
      session[:authorizenet_customer_id] = nil

      begin
        Spree::Gateway::AuthorizeNetCim.first
          .create_payment_methods_from_customer_profile(customer_id, try_spree_current_user)
      rescue => ex
        flash[:error] = ex.message
      end

      head :no_content
    end

    private

    def check_customer_id
      return if session[:authorizenet_customer_id]
      render json: { error: 'No customer ID present' }, status: :unprocessable_entity
    end

    def change_xframe_opts
      user_agent = UserAgent.parse(request.user_agent)
      return unless user_agent.browser == 'Chrome'

      major_version = user_agent.version.to_a[0]
      return unless major_version >= 60

      response.headers.delete('X-Frame-Options')
      response.headers['Content-Security-Policy'] = 'frame-ancestors https://*.educationaltechnologyinnovations.com https://*.umn.edu https://*.authorize.net'
    end
  end
end
