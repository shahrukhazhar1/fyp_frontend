$(document).ready ->
  $('#owner_id').on 'change', ->
    Turbolinks.visit "/plans/devices/#{$('#owner_id').val()}/subscriptions"
