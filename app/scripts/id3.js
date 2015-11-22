// Generated by CoffeeScript 1.9.3
(function() {
  var Node, mostCommon;

  window.DQ_ID3 = {};

  Node = {
    display: function() {
      if (this.terminal) {
        return "Terminal: " + this.label;
      } else {
        return "Decision on " + this.label;
      }
    },
    decide: function(datum, callback) {
      if (typeof callback === "function") {
        callback(this);
      }
      if (this.terminal) {
        return this.label;
      } else if (datum[this.attribute.name] !== '?') {
        return this.children[datum[this.attribute.name]].decide(datum, callback);
      } else {
        return '?';
      }
    }
  };


  /*
   * mostCommon(Array<Object> data, String attribute)
   * returns the most common value for the specified attribute within the set
   */

  mostCommon = function(data, attribute) {
    return _.max(_.pairs(_.countBy(data, attribute)), 1)[0];
  };


  /*
   * generate_tree(Array<Object> data, Array<Attribute> attributes, Attribute target)
   * Attributes are of the form:
   * {name: 'color', classes: ['red', 'blue', 'green']}
   * runs the ID3 algorithm and
   * returns the root node of a decision tree for the target attribute
   */

  DQ_ID3.generate_tree = function(data, attributes, target, maxDepth) {
    var child, i, len, ref, root, subset, uniqueLabels, unusedAttributes, value;
    root = Object.create(Node);
    uniqueLabels = _.uniq(_.pluck(data, target.name));
    if (uniqueLabels.length === 1) {
      root.terminal = true;
      root.label = uniqueLabels[0];
    } else if (attributes.length === 0 || maxDepth === 0) {
      root.terminal = true;
      root.label = mostCommon(data, target.name);
    } else {
      root.attribute = _.max(attributes, function(attr) {
        return DQ_ID3.IG(attr, data, target);
      });
      root.igData = _.object(_.pluck(attributes, 'name'), _.map(attributes, function(attr) {
        return DQ_ID3.IG(attr, data, target);
      }));
      root.children = {};
      ref = root.attribute.classes;
      for (i = 0, len = ref.length; i < len; i++) {
        value = ref[i];
        subset = _.where(data, _.object([root.attribute.name], [value]));
        if (subset.length === 0) {
          child = Object.create(Node);
          child.terminal = true;
          child.label = mostCommon(data, target.name);
        } else {
          unusedAttributes = _.reject(attributes, {
            name: root.attribute.name
          });
          child = DQ_ID3.generate_tree(subset, unusedAttributes, target, maxDepth - 1);
        }
        root.children[value] = child;
      }
    }
    return root;
  };


  /*
   * H(Array<Object> data, Attribute target)
   * Determine the Entropy:
   *   H(S) = - sum[x in X]{ p(x) * log_2(p(x)) }
   *   where
   *   - X is the subsets created from splitting S by the target
   *   - p(x) is the size of x divided by the size of S
   */

  DQ_ID3.H = function(data, target) {
    var counts, entropy, i, len, p, ref, value;
    entropy = 0;
    counts = _.countBy(data, target.name);
    ref = target.classes;
    for (i = 0, len = ref.length; i < len; i++) {
      value = ref[i];
      if (_.isNumber(counts[value])) {
        p = counts[value] / data.length;
        entropy -= p * Math.log2(p);
      }
    }
    return entropy;
  };


  /*
   * IG(Attribute attribute, Array<Object> data, Attribute target)
   * Determine the Information Gain:
   *   IG(A,S) = H(S) - sum[t in T]{ H(t) * p(t) }
   *   where
   *   - H(x) is the entropy of x with respect to the target
   *   - T is the subsets created from splitting S by A
   *   - p(t) is the size of t divided by the size of S
   */

  DQ_ID3.IG = function(attribute, data, target) {
    var i, len, originalEntropy, ref, splitEntropy, subset, value;
    originalEntropy = DQ_ID3.H(data, target);
    splitEntropy = 0;
    ref = attribute.classes;
    for (i = 0, len = ref.length; i < len; i++) {
      value = ref[i];
      subset = _.where(data, _.object([attribute.name], [value]));
      if (!_.isEmpty(subset)) {
        splitEntropy += DQ_ID3.H(subset, target) * subset.length / data.length;
      }
    }
    return originalEntropy - splitEntropy;
  };

}).call(this);
