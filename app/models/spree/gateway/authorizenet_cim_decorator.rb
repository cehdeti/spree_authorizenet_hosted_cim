Spree::Gateway::AuthorizeNetCim.class_eval do
  def get_hosted_form_token_for_order(order, params = {})
    profile_id = create_customer_profile_from_order(order)
    get_hosted_form_token(profile_id, params)
  end

  def create_customer_profile_from_order(order)
    response = cim_gateway.create_customer_profile(
      profile: {
        merchant_customer_id: "#{Time.now.to_f}",
        email: order.user.try(:email)
      },
      validation_mode: :none
    )

    if response.success?
      response.params['customer_profile_id']
    else
      raise ::Spree::Core::GatewayError.new(response.message)
    end
  end

  def get_hosted_form_token(profile_id, params = {})
    response = cim_gateway.get_hosted_profile_page(params.merge(customer_profile_id: profile_id))

    if response.success?
      response.params['token']
    else
      raise ::Spree::Core::GatewayError.new(response.message)
    end
  end

  def get_hosted_form_url(action)
    cim_gateway.get_hosted_profile_url(action)
  end

  def create_payment_methods_from_customer_profile(profile_id, user)
    response = cim_gateway.get_customer_profile(customer_profile_id: profile_id)
    raise ::Spree::Core::GatewayError.new(response.message) unless response.success?

    Array.wrap(response.params['profile']['payment_profiles']).each do |profile|
      case
      when profile['payment'].key?('credit_card')
        create_credit_card_from_customer_payment_profile(profile, profile_id, user)
      when profile['payment'].key?('bank_account')
        create_bank_account_from_customer_payment_profile(profile, profile_id, user)
      else
        raise 'Unknown payment method type'
      end
    end
  end

  private

  def create_credit_card_from_customer_payment_profile(profile, customer_profile_id, user)
    address = create_address_from_customer_payment_profile(profile)

    now = Time.now.utc
    Spree::CreditCard.create!(
      # We need to make a bogus expiration date here since authorize.net does
      # not return the real expiration date in its response.
      month: now.month, year: now.year + 2,

      cc_type: profile['payment']['credit_card']['card_type'].downcase.underscore.gsub(' ', '_'),
      last_digits: profile['payment']['credit_card']['card_number'].last(4),
      address_id: address.id,
      gateway_customer_profile_id: customer_profile_id,
      gateway_payment_profile_id: profile['customer_payment_profile_id'],
      name: "#{profile['bill_to']['first_name']} #{profile['bill_to']['last_name']}",
      user_id: user.id,
      payment_method_id: id
    )
  end

  # This is a stub method to handle bank accounts.
  #
  # If your store supports bank accounts as a payment method, override this
  # method and save the bank account in your system.
  #
  # - profile: A hash of the payment profile from Authorize.net
  # - customer_profile_id: The profile ID of the current customer
  # - user: The currently-logged-in user
  def create_bank_account_from_customer_payment_profile(profile, customer_profile_id, user)
    raise BankAccountsNotAccepted.new
  end \
    unless method_defined?(:create_bank_account_from_customer_payment_profile) || \
      private_method_defined?(:create_bank_account_from_customer_payment_profile)

  def create_address_from_customer_payment_profile(profile)
    Spree::Address.new(
      firstname: profile['bill_to']['first_name'],
      lastname: profile['bill_to']['last_name'],
      address1: profile['bill_to']['address'],
      city: profile['bill_to']['city'],
      zipcode: profile['bill_to']['zip'],
      phone: profile['bill_to']['phone_number'],
      company: profile['bill_to']['company'],
      state_name: profile['bill_to']['state']
    ).tap do |address|
      address.country = Spree::Country.find_by_name(profile['bill_to']['country']) || Spree::Country.default
      address.state = address.country.states.find_all_by_name_or_abbr(profile['bill_to']['state']).first
      address.save!
    end
  end

  class BankAccountsNotAccepted < RuntimeError
    def initialize; end

    def message
      Spree.t('authorizenet_hosted_cim.bank_accounts_not_accepted')
    end
  end
end
