var wordsmith = angular.module('wordsmith', ['ngRoute','firebase']); 
wordsmith.config(
  function($routeProvider, $locationProvider){
    $locationProvider.html5Mode(true);
    $routeProvider
    .when('/', {
      controller: 'playerController',
      templateUrl: 'partials/word.html'
    })
  });