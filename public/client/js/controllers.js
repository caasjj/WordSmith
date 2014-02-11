 wordsmith.controller(
  'wordController',
  function($scope, $firebase) {
    var playerRef = new Firebase("https://wordsmith.firebaseio.com/players");
    var maxRef = new Firebase("https://wordsmith.firebaseio.com/");

      $scope.players  = $firebase(playerRef);
      $scope.currentWord = $firebase(maxRef );

      $scope.players.$on( 'loaded', function() {
      console.log( arguments );
      });
      $scope.currentWord.$on( 'loaded', function() {
        console.log( arguments[0] );
      });
   }); 