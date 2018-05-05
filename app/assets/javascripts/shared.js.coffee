$(document).ready ->

  jQuery('.fadeInUp').addClass("hidden").viewportChecker
    classToAdd: 'visible animated fadeInUp'
    offset: 100

  $('.switch')['bootstrapSwitch']()
  $("[data-toggle='switch']").wrap('<div class="switch" />').parent().bootstrapSwitch()

$(document).on 'page:load', ->

  $('.selectpicker').selectpicker()
