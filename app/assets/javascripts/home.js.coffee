# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'ready page:load', ->

  

	$('.device-switch').on 'change', ->
	  value = $(this).parent().hasClass('switch-on')
	  enabler = $("#edit_device_#{$(this).prop('id')}").children('#device_is_enabled')
	  $(enabler).val(value)
	  $("#edit_device_#{$(this).prop('id')}").submit()


