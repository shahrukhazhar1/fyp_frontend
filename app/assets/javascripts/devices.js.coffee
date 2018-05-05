# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


$(document).on 'ready page:load', ->
  if $('#devices-show').length > 0
    data1 = $('#milestones-chart').data('chart-stats')
    Morris.Line
      element: 'milestones-chart'
      data: data1
      xkey: 'y'
      ykeys: [
        'value'
      ]
      parseTime: false
      labels: [ 'Value' ]
      pointSize: 2

    data = $('#quiz-activity-chart').data('chart-stats')
    Morris.Bar
      element: 'quiz-activity-chart'
      data: data
      xkey: 'y'
      ykeys: [
        'a'
      ]
      labels: [
        'Quiz'
      ]

    showQuizActivityChart = ->
      $('#milestones-chart').hide()
      $('#quiz-activity-chart').show()

    showMilestonesChart = ->
      $('#quiz-activity-chart').hide()
      $('#milestones-chart').show()

    plotchart = ->
      if $('#progress-chart-type').val() is '0'
        showQuizActivityChart()
      else
        showMilestonesChart()

    plotchart()

    $('#progress-chart-type').on 'change', ->
      plotchart()
