module Spree
  class AuthorizenetHostedFormController < Spree::BaseController
    layout false

    before_action :check_customer_id, only: :add_payment

    def iframe
    end

    def add_payment
      customer_id = session[:authorizenet_customer_id]
      session[:authorizenet_customer_id] = nil
      Spree::Gateway::AuthorizeNetCim.first
        .create_credit_cards_from_customer_profile(customer_id, try_spree_current_user)
      head :no_content
    end

    private

    def check_customer_id
      return if session[:authorizenet_customer_id]
      render json: { error: 'No customer ID present' }, status: :unprocessable_entity
    end
  end
end
