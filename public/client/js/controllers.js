 wordsmith.controller(
  'wordController',
  function($scope, $firebase) {
    var playerRef = new Firebase("https://wordsmith.firebaseio.com/players");
    var maxRef = new Firebase("https://wordsmith.firebaseio.com/");
      // Automatically syncs everywhere in realtime
      $scope.players = $firebase(playerRef);
      $scope.maxValue = $firebase(maxRef );
      //$scope.players.$add({'username':'player', 'word':'none'});
      //console.log( 'here', $scope.data.$child('player0'));
      //v = $scope.data.$child('player0').$child('available').$value;
      $scope.players.$on( 'loaded', function() {
      console.log( arguments );
      });
      $scope.maxValue.$on( 'loaded', function() {
        console.log( arguments[0] );
      });
   }); 