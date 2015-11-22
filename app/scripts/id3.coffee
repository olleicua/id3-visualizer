window.DQ_ID3 = {}

# A decision tree node
Node =

  # A text description of the node
  display: ->
    if @terminal
      "Terminal: #{@label}"
    else
      "Decision on #{@label}"

  # decide which label the datum belongs to
  decide: (datum, callback) ->
    callback?(@)
    if @terminal
      @label
    else if datum[@attribute.name] isnt '?'
      @children[datum[@attribute.name]].decide(datum, callback)
    else
      '?'

###
# mostCommon(Array<Object> data, String attribute)
# returns the most common value for the specified attribute within the set
###
mostCommon = (data, attribute) ->
  _.max(_.pairs(_.countBy(data, attribute)), 1)[0]

###
# generate_tree(Array<Object> data, Array<Attribute> attributes, Attribute target)
# Attributes are of the form:
# {name: 'color', classes: ['red', 'blue', 'green']}
# runs the ID3 algorithm and
# returns the root node of a decision tree for the target attribute
###
DQ_ID3.generate_tree = (data, attributes, target, maxDepth) ->
  root = Object.create Node

  # check if all examples have the same label
  uniqueLabels = _.uniq(_.pluck(data, target.name))
  if uniqueLabels.length is 1
    root.terminal = true
    root.label = uniqueLabels[0]

  # check if there are no attributes left to decide on
  else if attributes.length is 0 or maxDepth is 0
    root.terminal = true
    root.label = mostCommon(data, target.name)

  # split on an attribute
  else

    # choose the attribute
    root.attribute = _.max(attributes, (attr) -> DQ_ID3.IG(attr, data, target))
    root.igData = _.object(_.pluck(attributes, 'name'),
                           _.map(attributes,
                                 (attr) -> DQ_ID3.IG(attr, data, target)))
    root.children = {}
    for value in root.attribute.classes
      subset = _.where(data, _.object([root.attribute.name], [value]))

      # no data match this value; create terminal node
      if subset.length is 0
        child = Object.create Node
        child.terminal = true
        child.label = mostCommon(data, target.name)

      # run ID3 recursively on the subset
      else
        unusedAttributes = _.reject(attributes, name: root.attribute.name)
        child = DQ_ID3.generate_tree(subset,
                                     unusedAttributes,
                                     target,
                                     maxDepth - 1)

      root.children[value] = child

  # return root
  root

###
# H(Array<Object> data, Attribute target)
# Determine the Entropy:
#   H(S) = - sum[x in X]{ p(x) * log_2(p(x)) }
#   where
#   - X is the subsets created from splitting S by the target
#   - p(x) is the size of x divided by the size of S
###
DQ_ID3.H = (data, target) ->
  entropy = 0
  counts = _.countBy(data, target.name)
  for value in target.classes
    if _.isNumber counts[value]
      p = counts[value] / data.length
      entropy -= p * Math.log2(p)
  entropy

###
# IG(Attribute attribute, Array<Object> data, Attribute target)
# Determine the Information Gain:
#   IG(A,S) = H(S) - sum[t in T]{ H(t) * p(t) }
#   where
#   - H(x) is the entropy of x with respect to the target
#   - T is the subsets created from splitting S by A
#   - p(t) is the size of t divided by the size of S
###
DQ_ID3.IG = (attribute, data, target) ->

  # calculate starting entropy
  originalEntropy = DQ_ID3.H(data, target)

  # calculate entropy after split
  splitEntropy = 0
  for value in attribute.classes
    subset = _.where(data, _.object([attribute.name], [value]))
    unless _.isEmpty subset
      splitEntropy += DQ_ID3.H(subset, target) * subset.length / data.length

  # return information gain
  originalEntropy - splitEntropy
