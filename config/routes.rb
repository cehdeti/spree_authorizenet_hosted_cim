Spree::Core::Engine.routes.draw do
  get '/authorizenet_iframe_communicator', to: 'authorizenet_hosted_form#iframe',
                                           as: :authorizenet_iframe_communicator
  post '/authorizenet_form_callback/addPayment', to: 'authorizenet_hosted_form#add_payment',
                                                 as: :authorizenet_hosted_form_add_payment_callback
end
