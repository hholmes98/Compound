// knapsack.cfc
component accessors = "true" {
  // The knapsack problem asks, given a set of items of various weights, find a subset or subsets of items such that their total weight is no larger than some given capacity but as large as possible.
  // This module solves a special case of the 0-1 knapsack problem when the value of each item is equal to its weight. Capacity and weights are restricted to positive integers.
  //
  // Port of PERL script @ http://cpansearch.perl.org/src/ANDALE/Algorithm-Knapsack-0.02/lib/Algorithm/Knapsack.pm
  //
  // inputs:
  // - weights: struct of numerics - keys are ids, values are weights.
  // - capacity: numeric - max sum of weights that can be sorted into each solution.
  // - verify: boolean (default: false) - if true, ensures a split can be accomodated (certain values prevent splitting)
  // NOTE: if you leave this false and weights cannnot split, you'll get an empty array as a result.
  // returns:
  // - array of lists of keys, in as many combinations that add up to but do not exceed capacity.
  // HINT: call solutions() to see the actual weights (in list form) of the aforementioned result array.
  variables.capacity = 0;
  variables.weights = StructNew();
  variables.solutions = ArrayNew(1);
  variables.emptiness = 0;

  remote any function knapsack(struct weights, numeric capacity, boolean verify=false) {

    variables.weights = arguments.weights;
    variables.capacity = arguments.capacity;

    // reset on call
    variables.solutions = ArrayNew(1);
    variables.emptiness = 0;

    if (arguments.verify)
        verify();

    compute();

    return variables.solutions;

  }

  remote any function solutions(struct weights, numeric capacity) {

    var sol = knapsack(arguments.weights, arguments.capacity);

    return sol.map(function(col){
      return col.map(function(key){
        return variables.weights[key];
      });
    });

  }

  remote any function weightlist() {
    var res = '';
    variables.weights.map(function(key){
      res = ListAppend(res, variables.weights[key]);
    });
    return res;
  }

  private any function verify() {

    for (var key in variables.weights) {
      if ( variables.weights[key] > variables.capacity ) {
        Throw( errorCode="ERR_KNAPSACK_CAPACITY_OVERFLOW", message="No solution exists for the specified parameters.", detail="For the weightlist [#weightlist()#], one value [#variables.weights[key]#], is greater than the specified capacity [#variables.capacity#]." );
      }
    }

  }

  private any function compute() {

    variables.emptiness = variables.capacity;

    var listIndexes = '';

    for ( var key in variables.weights ) {
      listIndexes = ListAppend( listIndexes, key );
    }

    process( variables.capacity, listIndexes, '' );

  }

  private any function process(numeric c, string indexes, string klist) {

    var inds = arguments.indexes;
    var k = arguments.klist;

    while ( ListLen(inds) > 0 ) {

      var next = ListGetAt(inds, 1);
      inds = ListDeleteAt(inds, 1);

      // if this weight > capacity, skip to next weight.
      if ( variables.weights[next] <= arguments.c ) {

        // if capacity - this weight is less than emptiness
        if ( arguments.c - variables.weights[next] < variables.emptiness ) {

          // emptiness is now capacity - this weight
          variables.emptiness = arguments.c - variables.weights[next];

          // reset solutions
          variables.solutions= ArrayNew(1);
        }

        // if capacity - this weight is equal to emptiness
        if ( arguments.c - variables.weights[next] == variables.emptiness ) {

          // append this key to the list passed in.
          var temp_k = ListAppend( k, next );

          // jam this list on to the current solutions.
          ArrayAppend( variables.solutions, temp_k );

        }

      }

      // on every iteration through:
      // 1. reduce the capacity by the current item's weight
      // 2. pass in the list of remaining keys, - the current key (line #77),
      // 3. pass in a growing list of keys that are under capacity, adding the current key
      var new_k = ListAppend( k, next );
      process(arguments.c - variables.weights[next], inds, new_k);

    }

  }

}