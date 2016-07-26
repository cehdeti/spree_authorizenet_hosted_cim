Deface::Override.new(
  virtual_path: 'spree/checkout/_address',
  name: 'make_shipping_address_static_in_checkout',
  replace_contents: "[data-hook='billing_fieldset_wrapper']",
  text: <<-TEXT
    <%= render partial: 'spree/shared/static_address_pane', locals: {
      title: Spree.t(:billing_address),
      address: @order.bill_address
    } %>
  TEXT
)
