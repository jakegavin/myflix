jQuery(function($) {
  $('#payment-form').submit(function(event) {
    var $form = $(this);
      $form.find('.submit_form').prop('disabled', true);
      Stripe.createToken($form, stripeResponseHandler);

      return false;
  });

    var stripeResponseHandler = function(status, response) {
      var $form = $('#payment-form')
      if (response.error) {
        $form.find(".payment-errors").text(response.error.message);
        $form.find('.submit_form').prop('disabled', false);
      } else {
        var form$ = $("#payment-form");
        var token = response['id'];
        form$.append("<input type='hidden' name='stripeToken' value='" + token + "'/>");
        form$.append("<input type='hidden' name='stripeToken' value='" + token + "'/>");
        form$.get(0).submit();
      }

    };
});