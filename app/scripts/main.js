// Generated by CoffeeScript 1.9.3
(function() {
  var DQ_ID3_Visualizer;

  DQ_ID3_Visualizer = {
    attributes: [],
    trainingData: [],
    testData: [],
    init: function() {
      _.extend(this, DQ_DATA_ADULT);
      this.displayAttributes();
      this.displayData('.training-data', this.trainingData);
      this.displayData('.test-data', this.testData);
      $('.rebuild-tree').click((function(_this) {
        return function() {
          return _this.rebuildTree();
        };
      })(this));
      $('.run-tests').click((function(_this) {
        return function() {
          return _this.runTests();
        };
      })(this));
      return _.each(this.testData, (function(_this) {
        return function(datum) {
          datum.elem.addClass('clickable');
          return datum.elem.click(function() {
            return _this.showTest(datum);
          });
        };
      })(this));
    },
    displayAttributes: function() {
      return _.each(this.attributes, (function(_this) {
        return function(attribute) {
          return $('.attributes .scrollable').append(_this.buildAttribute(attribute));
        };
      })(this));
    },
    buildAttribute: function(attribute) {
      return attribute.elem = $('<div>').addClass('attribute').append($('<b>').text(attribute.name)).append(" (" + (attribute.classes.join(', ')) + ")");
    },
    displayData: function(selector, data) {
      return _.each(data, (function(_this) {
        return function(datum) {
          return $(selector + " .scrollable").append(_this.buildDatum(datum));
        };
      })(this));
    },
    buildDatum: function(datum) {
      datum.elem = $('<div>').addClass('datum');
      _.each(this.attributes, (function(_this) {
        return function(attribute) {
          return datum.elem.append($('<b>').text(attribute.name)).append(":" + datum[attribute.name] + " ");
        };
      })(this));
      return datum.elem;
    },
    rebuildTree: function() {
      var attributes, maxDepth;
      maxDepth = parseFloat($('.max-depth').val());
      attributes = _.reject(this.attributes, {
        target: true
      });
      this.target = _.findWhere(this.attributes, {
        target: true
      });
      this.tree = DQ_ID3.generate_tree(this.trainingData, attributes, this.target, maxDepth);
      window.tree = this.tree;
      window.data = this.testData;
      this.resetTests();
      return this.displayTree();
    },
    displayTree: function() {
      var root;
      $('.tree .scrollable').empty();
      root = this.buildTree(this.tree, 'root').removeClass('closed').addClass('root');
      return $('.tree .scrollable').append(root);
    },
    buildTree: function(node, value) {
      var children, row, toggle;
      node.elem = $('<div>').addClass('tree-node closed');
      toggle = $('<div>').addClass('toggle');
      node.elem.append(toggle);
      row = $('<div>').addClass('tree-node-row');
      node.elem.append(row);
      if (value) {
        row.append($('<b>').text(value));
      }
      if (node.terminal) {
        node.elem.addClass('terminal');
        row.append(": " + node.label);
      } else {
        toggle.click(function() {
          return node.elem.toggleClass('closed');
        });
        row.click((function(_this) {
          return function() {
            node.elem.removeClass('closed');
            return _this.showIG(node.igData, row);
          };
        })(this));
        row.append(": split on " + node.attribute.name);
        children = $('<div>').addClass('tree-node-children');
        node.elem.append(children);
        _.each(_.pairs(node.children), (function(_this) {
          return function(arg) {
            var childNode, value;
            value = arg[0], childNode = arg[1];
            return children.append(_this.buildTree(childNode, value));
          };
        })(this));
      }
      return node.elem;
    },
    showIG: function(igData, domNode) {
      this.resetTree();
      domNode.addClass('correct');
      domNode.removeClass('closed');
      domNode.parents('.tree-node').removeClass('closed');
      this.resetAttributes();
      return _.each(this.attributes, function(attribute) {
        var ig, igBox;
        if (_.isNumber(igData[attribute.name])) {
          attribute.elem.addClass('correct');
          ig = Math.round(igData[attribute.name] * 100) / 100;
          igBox = $('<div>').addClass('ig').text(ig);
          return attribute.elem.prepend(igBox);
        }
      });
    },
    resetTests: function() {
      this.resetData();
      this.resetTree();
      return this.resetAttributes();
    },
    resetData: function() {
      $('.datum').removeClass('correct incorrect');
      return $('.datum .result-box').remove();
    },
    resetTree: function() {
      $('.tree-node').addClass('closed');
      $('.tree-node.root').removeClass('closed');
      return $('.tree-node-row').removeClass('correct incorrect');
    },
    resetAttributes: function() {
      $('.attribute').removeClass('correct incorrect');
      return $('.attribute .ig').remove();
    },
    runTests: function() {
      if (!this.tree) {
        return;
      }
      this.resetTests();
      return _.each(this.testData, (function(_this) {
        return function(datum) {
          return _this.runTest(datum);
        };
      })(this));
    },
    runTest: function(datum) {
      var klass, result, resultBox;
      if (!this.tree) {
        return;
      }
      result = this.tree.decide(datum);
      datum.elem.find('.result-box').remove();
      resultBox = $('<div>').addClass('result-box').append(result);
      datum.elem.prepend(resultBox);
      klass = result === datum[this.target.name] ? 'correct' : 'incorrect';
      datum.elem.addClass(klass);
      return klass;
    },
    showTest: function(datum) {
      var klass;
      if (!this.tree) {
        return;
      }
      this.resetAttributes();
      this.resetTree();
      klass = this.runTest(datum);
      return this.tree.decide(datum, (function(_this) {
        return function(node) {
          node.elem.find('> .tree-node-row').addClass(klass);
          if (!node.terminal) {
            return node.elem.removeClass('closed');
          }
        };
      })(this));
    }
  };

  DQ_ID3_Visualizer.init();

}).call(this);
