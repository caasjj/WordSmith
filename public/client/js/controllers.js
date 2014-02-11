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

 wordsmith.controller(
  'letterController',
  function($scope, $http) {
    $scope.submit = function() {
      console.log('Letter submitted', this.text);
      console.log( $scope.player );
      console.log( $scope.player.id )
      $http.post('/players/-JFXH08rzxnMwWkUoKSJ/char/' + this.text );
      this.text = "";
    }
  });