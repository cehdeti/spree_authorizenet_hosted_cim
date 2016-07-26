Deface::Override.new(
  virtual_path: 'spree/checkout/edit',
  name: 'add_authorizenet_hosted_form',
  insert_bottom: "[data-hook='checkout_form_wrapper']",
  text: <<-TEXT
    <%= render partial: 'spree/checkout/payment/authorizenet_form', locals: {
      form_url: @authorizenet_form_url,
      token: @authorizenet_token,
      options: @authorizenet_form_options
    } if @authorizenet_form_url %>
  TEXT
)
