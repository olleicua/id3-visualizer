DQ_ID3_Visualizer =
  attributes: []
  training_data: []
  test_data: []

  init: ->
    $.ajax
      method: 'GET'
      url: 'file://data/adult.json'
      dataType: 'json'
      success: (x...) -> console.log x

DQ_ID3_Visualizer.init()
