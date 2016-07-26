Spree::Address.class_eval do
  def require_phone?
    false
  end
end
