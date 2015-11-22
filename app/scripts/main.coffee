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
    $('.run-tests').click => @runTests()
    _.each @testData, (datum) =>
      datum.elem.addClass 'clickable'
      datum.elem.click => @showTest(datum)

  # generate the DOM for the attributes section
  displayAttributes: ->
    _.each @attributes, (attribute) =>
      $('.attributes .scrollable').append @buildAttribute(attribute)

  # generate the DOM for a row of the attributes section
  buildAttribute: (attribute) ->
    attribute.elem = $('<div>')
      .addClass 'attribute'
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
    maxDepth = parseFloat $('.max-depth').val()
    attributes = _.reject @attributes, target: true
    @target = _.findWhere @attributes, target: true
    @tree = DQ_ID3.generate_tree(@trainingData, attributes, @target, maxDepth)

    # expose to console
    window.tree = @tree
    window.data = @testData

    # genderate DOM for the tree
    @resetTests()
    @displayTree()

  # generate the DOM for the tree
  displayTree: ->
    $('.tree .scrollable').empty()
    root = @buildTree(@tree, 'root')
      .removeClass('closed')
      .addClass('root')
    $('.tree .scrollable').append root

  # generate the DOM for a level of the tree
  buildTree: (node, value) ->
    node.elem = $('<div>').addClass 'tree-node closed'
    toggle = $('<div>').addClass 'toggle'
    node.elem.append toggle
    row = $('<div>').addClass 'tree-node-row'
    node.elem.append row
    row.append $('<b>').text value if value
    if node.terminal
      node.elem.addClass 'terminal'
      row.append ": #{node.label}"
    else
      toggle.click -> node.elem.toggleClass 'closed'
      row.click =>
        node.elem.removeClass 'closed'
        @showIG(node.igData, row)
      row.append ": split on #{node.attribute.name}"
      children = $('<div>').addClass 'tree-node-children'
      node.elem.append children
      _.each _.pairs(node.children), ([value, childNode]) =>
        children.append @buildTree(childNode, value)
    node.elem

  # display info gain on attributes
  showIG: (igData, domNode) ->

    # show selection in tree
    @resetTree()
    domNode.addClass 'correct'
    domNode.removeClass 'closed'
    domNode.parents('.tree-node').removeClass 'closed'

    # show selected IG
    @resetAttributes()
    _.each @attributes, (attribute) ->
      if _.isNumber igData[attribute.name]
        attribute.elem.addClass 'correct'
        ig = Math.round(igData[attribute.name] * 100) / 100
        igBox = $('<div>').addClass('ig').text(ig)
        attribute.elem.prepend igBox

  # reset all of the data rows to blue
  resetTests: ->
    @resetData()
    @resetTree()
    @resetAttributes()

  # reset all of the data rows to blue
  resetData: ->
    $('.datum').removeClass('correct incorrect')
    $('.datum .result-box').remove()

  # close and reset the tree
  resetTree: ->
    $('.tree-node').addClass('closed')
    $('.tree-node.root').removeClass('closed')
    $('.tree-node-row').removeClass('correct incorrect')

  # reset all of the attribute rows to blue
  resetAttributes: ->
    $('.attribute').removeClass('correct incorrect')
    $('.attribute .ig').remove()

  # test each row of the test data set on the tree
  runTests: ->
    return unless @tree

    @resetTests()
    _.each @testData, (datum) => @runTest(datum)

  # test a row of the test data set on the tree
  runTest: (datum) ->
    return unless @tree

    result = @tree.decide(datum)
    datum.elem.find('.result-box').remove()
    resultBox = $('<div>')
      .addClass 'result-box'
      .append result
    datum.elem.prepend resultBox
    klass = if result is datum[@target.name] then 'correct' else 'incorrect'
    datum.elem.addClass klass
    klass

  # display the path through the tree of a specific datum
  showTest: (datum) ->
    return unless @tree

    @resetAttributes()
    @resetTree()
    klass = @runTest(datum)
    @tree.decide datum, (node) =>
      node.elem.find('> .tree-node-row').addClass(klass)
      node.elem.removeClass('closed') unless node.terminal

DQ_ID3_Visualizer.init()
