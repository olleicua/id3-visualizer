DQ_ID3_Visualizer =
  attributes: []
  trainingData: []
  testData: []

  init: ->
    # load data
    _.extend @, DQ_DATA_ADULT

    # init DOM
    @displayAttributes()
    @displayData('.training-data', @trainingData)
    @displayData('.test-data', @testData)

    # event hooks
    $('.rebuild-tree').click => @rebuildTree()

  # generate the DOM for the attributes section
  displayAttributes: ->
    _.each @attributes, (attribute) =>
      $('.attributes .scrollable').append @buildAttribute(attribute)

  # generate the DOM for a row of the attributes section
  buildAttribute: (attribute) ->
    attribute.elem = $('<div>')
      .addClass 'attribute'
      .append $('<div>').addClass 'ig'
      .append $('<b>').text attribute.name
      .append " (#{attribute.classes.join(', ')})"

  # generate the DOM for a data section
  displayData: (selector, data) ->
    _.each data, (datum) =>
      $("#{selector} .scrollable").append @buildDatum(datum)

  # generate the DOM for a row of a data section
  buildDatum: (datum) ->
    datum.elem = $('<div>').addClass 'datum'
    _.each @attributes, (attribute) =>
      datum.elem
        .append $('<b>').text attribute.name
        .append ":#{datum[attribute.name]} "
    datum.elem

  rebuildTree: ->
    # generate tree
    attributes = _.reject @attributes, target: true
    target = _.findWhere @attributes, target: true
    @tree = DQ_ID3.generate_tree(@trainingData, attributes, target)

    # expose to console
    window.tree = @tree
    window.data = @testData

    # genderate DOM for the tree
    @displayTree()

  # generate the DOM for the tree
  displayTree: ->
    root = @buildTree(@tree, 'root')
      .removeClass('closed')
      .addClass('root')
    $('.tree .scrollable').append root

  # generate the DOM for a level of the tree
  buildTree: (node, value) ->
    node.elem = $('<div>').addClass 'tree-node closed'
    row = $('<div>').addClass 'tree-node-row'
    node.elem.append row
    row.append $('<b>').text value if value
    if node.terminal
      node.elem.addClass 'terminal'
      row.append ": #{node.label}"
    else
      row.click -> node.elem.toggleClass 'closed'
      row.append ": split on #{node.attribute.name}"
      children = $('<div>').addClass 'tree-node-children'
      node.elem.append children
      _.each _.pairs(node.children), ([value, childNode]) =>
        children.append @buildTree(childNode, value)
    node.elem

DQ_ID3_Visualizer.init()
