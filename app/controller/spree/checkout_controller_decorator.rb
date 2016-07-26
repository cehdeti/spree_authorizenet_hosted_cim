Spree::CheckoutController.class_eval do
  before_action :load_authorizenet_hosted_form, only: :edit

  private

  def load_authorizenet_hosted_form
    return unless @order.payment? && authorizenet_cim_enabled?

    gateway = Spree::Gateway::AuthorizeNetCim.first
    session[:authorizenet_customer_id] ||= gateway.create_customer_profile_from_order(@order)
    @authorizenet_token = gateway.get_hosted_form_token(session[:authorizenet_customer_id],
      page_border_visible: false,
      iframe_communicator_url: authorizenet_iframe_communicator_url,
      billing_address_required: true,
      card_code_required: true
    )
    @authorizenet_form_url = gateway.get_hosted_form_url(:add_payment)
  end

  def authorizenet_cim_enabled?
    Spree::Gateway::AuthorizeNetCim.active.any?
  rescue
    false
  end

  def authorizenet_customer_id
  end
end
