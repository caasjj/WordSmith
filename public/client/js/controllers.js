wordsmith.controller(
  'playerController',
  function($scope, $firebase) {
    var playerRef = new Firebase("https://wordsmith.firebaseio.com/players");
      // Automatically syncs everywhere in realtime
      $scope.players = $firebase(playerRef);
      
      //$scope.players.$add({'username':'player', 'word':'none'});
      //console.log( 'here', $scope.data.$child('player0'));
      //v = $scope.data.$child('player0').$child('available').$value;
      $scope.players.$on( 'loaded', function() {
      console.log( arguments );
    });

   }); 
