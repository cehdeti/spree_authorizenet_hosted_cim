Spree::CheckoutController.class_eval do
  before_action :load_authorizenet_hosted_form, only: :edit

  after_action :change_xframe_opts

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

  # Overridden from `spree_frontend`.
  #
  # Removes the stock check so that our order doesn't get cleared out, since we
  # don't have any shipments yet. That functionality is moved to the
  # `before_confirm` method below.
  def before_payment
    if try_spree_current_user && try_spree_current_user.respond_to?(:payment_sources)
      @payment_sources = try_spree_current_user.payment_sources
    end
  end

  # NOTE: If the upstream `spree_frontend` definition of this controller ever
  # implements this method, we'll need to add that in here.
  raise "`before_confirm` method already imeplement in `spree_frontend`" \
    if method_defined?(:before_confirm) || private_method_defined?(:before_confirm)

  #this extension puts normal spree before_payment functionality in before_confirm
  #the Spree Product Assembly extension doesn't want anything in before_payment
  #so check if SpreeProductAssembly is installed and don't do anything if it is
  #note, this may cause issues in the case where someone is using the Stock functionality
  def before_confirm
    if !defined?(SpreeProductAssembly)
      if @order.checkout_steps.include? "delivery"
        packages = @order.shipments.map(&:to_package)
        @differentiator = Spree::Stock::Differentiator.new(@order, packages)
        @differentiator.missing.each do |variant, quantity|
          @order.contents.remove(variant, quantity)
        end
      end
    end
  end


  def change_xframe_opts
    puts("CHANGING XFRAME OPTS Controller!!!!")

    user_agent = UserAgent.parse(request.user_agent)
    puts("User agent: #{user_agent}")

    if user_agent.browser == 'Chrome'

      varr = user_agent.version.to_a
      vmajor = varr[0]

      if vmajor >= 60
        response.headers.delete('X-Frame-Options')
        response.headers['Content-Security-Policy'] = "frame-ancestors https://*.educationaltechnologyinnovations.com https://*.umn.edu https://*.authorize.net"
      end

    end
  end

end
