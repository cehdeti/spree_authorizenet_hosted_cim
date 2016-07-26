(function($) {
  var AuthorizenetHostedForm = {};

  AuthorizenetHostedForm.getModal = function() {
    return $('#authorizenet-hosted-form-modal');
  };

  AuthorizenetHostedForm.getForm = function() {
    return $('#authorizenet-hosted-form');
  };

  AuthorizenetHostedForm.onCancel = function(data) {
    this.getModal().modal('hide');
  };

  AuthorizenetHostedForm.onSuccessfulSave = function(data) {
    this.getModal().modal('hide');

    $.post('/authorizenet_form_callback/addPayment', function(data) {
      window.location.reload();
    });
  };

  AuthorizenetHostedForm.handleEvent = function(event) {
    var data = this._parseEventData(event),
        action = data.action,
        method = "on" + action.charAt(0).toUpperCase() + action.slice(1);

    if (this.hasOwnProperty(method)) {
      this[method](data);
    }
  };

  AuthorizenetHostedForm._parseEventData = function(event) {
		var vars = {};
		var arr = event.data.split('&');
		var pair;
		for (var i = 0; i < arr.length; i++) {
			pair = arr[i].split('=');
			vars[pair[0]] = unescape(pair[1]);
		}
		return vars;
	};

  $(document).ready(function() {
    $('#authorizenet-open-hosted-form').click(function(event) {
      event.preventDefault();
      AuthorizenetHostedForm.getForm().submit();
      AuthorizenetHostedForm.getModal().modal('show');
      return false;
    });
  });

  window.AuthorizenetHostedForm = AuthorizenetHostedForm;
})(jQuery);
