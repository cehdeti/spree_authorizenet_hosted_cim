Spree::Order.class_eval do
  # Redefine the checkout flow to place the `payment` step before the `address`
  # step, since the user is required to enter their billing address on
  # Authorize.net's hosted form.
  checkout_flow do
    go_to_state :payment, if: ->(order) { order.payment_required? }
    go_to_state :address
    go_to_state :delivery
    go_to_state :confirm, if: ->(order) { order.confirmation_required? }
    go_to_state :complete
  end

  state_machine.after_transition from: :delivery, do: :update_payment_total_with_shipping

  private

  def update_payment_total_with_shipping
    payment = payments.valid.first
    return unless payment && payment.amount != total
    payment.update!(amount: total)
  end

  # Overridden to grab the default billing/shipping addresses from the payment
  # method entered previously.
  def assign_default_addresses!
    if payments.any?
      clone_billing_from_payments
      clone_shipping_from_payments if checkout_steps.include?("delivery")
    elsif user
      clone_billing
      clone_shipping if checkout_steps.include?("delivery")
    end
  end

  def clone_billing_from_payments
    return if bill_address_id
    address = address_from_payments
    self.bill_address = address.try(:clone) if address.try(:valid?)
  end

  def clone_shipping_from_payments
    return if ship_address_id
    address = address_from_payments
    self.ship_address = address.try(:clone) if address.try(:valid?)
  end

  def address_from_payments
    logger.debug "GETTING ADDRESS FROM PAYMENST #{payments.count}"
    payment=nil
    address=nil
    payments.each do |p|
      logger.debug "GOING THROUGH PAYMENT: #{p} #{p.source}"
      if p.source.present? && p.source.address_id.present?
        logger.debug "found payment with source!"
        payment=p
        logger.debug "payment is : #{payment}"
        break
      end
    end
    if payment
      logger.debug "we have payment:: #{payment}"
      address=Spree::Address.find(payment.source.address_id) if payment.source.address_id
      logger.debug "had payment, now found the address: #{address}"
      return address
    end
    return nil
  end
end
