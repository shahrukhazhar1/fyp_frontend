//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require jquery_nested_form
//= require turbolinks
//= require bootstrap
//= require dnd
//= require switch
//= require viewport-checker
//= require bootstrap-select
//= require plans
//= require devices
//= require home
//= require shared
//= require select2.full
//= require select2.full.min
//= require select2
//= require select2.min

$(document).ready(function(){
  $('.dropdown-toggle').dropdown();
});

$(document).on('page:change', function () {
  $(".filter-bar input[type='checkbox']").on('click',function(){
      $(this).closest('form').submit();
  });
});