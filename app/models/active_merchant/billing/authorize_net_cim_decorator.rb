require 'active_merchant/billing/gateways/authorize_net_cim'

# This is _really_ bad form, updating a constant like this.
#
# Keep an eye on this as you upgrade ActiveMerchant.
ActiveMerchant::Billing::AuthorizeNetCimGateway::CIM_ACTIONS[:get_hosted_profile_page] = 'getHostedProfilePage'

ActiveMerchant::Billing::AuthorizeNetCimGateway.class_eval do
  class_attribute :test_hosted_form_url, :live_hosted_form_url

  self.test_hosted_form_url = 'https://test.authorize.net/customer'
  self.live_hosted_form_url = 'https://accept.authorize.net/customer'

  # Retrieve a hosted form token for a given customer.
  #
  # Returns a Response whose params hash contains a hosted form token.
  #
  # ==== Options
  #
  # * <tt>:customer_profile_id</tt> -- The Customer Profile ID of the customer. (REQUIRED)
  def get_hosted_profile_page(options = {})
    requires!(options, :customer_profile_id)

    request = build_request(:get_hosted_profile_page, options)
    commit(:get_hosted_profile_page, request)
  end

  def build_get_hosted_profile_page_request(xml, options = {})
    xml.tag!('customerProfileId', options[:customer_profile_id])
    xml.tag!('hostedProfileSettings') do |settings|
      add_authorizenet_hosted_profile_setting(settings, 'hostedProfileValidationMode', test? ? 'testMode' : 'liveMode')

      {
        return_url: 'hostedProfileReturnUrl',
        return_url_text: 'hostedProfileReturnUrlText',
        page_border_visible: 'hostedProfilePageBorderVisible',
        heading_bg_color: 'hostedProfileHeadingBgColor',
        iframe_communicator_url: 'hostedProfileIFrameCommunicatorUrl',
        billing_address_required: 'hostedProfileBillingAddressRequired',
        card_code_required: 'hostedProfileCardCodeRequired'
      }.each_pair do |param, tag|
        next unless options[param]
        add_authorizenet_hosted_profile_setting(settings, tag, options[param])
      end
    end

    xml.target!
  end

  def get_hosted_profile_url(action)
    url = test? ? test_hosted_form_url : live_hosted_form_url
    "#{url}/#{action.to_s.camelize(:lower)}"
  end

  private

  def add_authorizenet_hosted_profile_setting(settings_xml, name, value)
    settings_xml.tag!('setting') do |setting|
      setting.settingName(name)
      setting.settingValue(value)
    end
    settings_xml
  end
end
