angular.module('temperature', [])
.controller('MainCtrl', ['$scope','$http',
  function($scope,$http){
    $scope.temperatures = [];
    $scope.violations = [];
    $scope.eci = "cklyj9kt4000gqsuwgduc44rk";
    $scope.temp = "not loaded";

    var gURL = 'http://localhost:3000/c/'+$scope.eci+'/query/temperature_store/temperatures';
    $scope.getAll = function() {
      return $http.get(gURL).success(function(data){
        var recent = data.sort(function(temp) {return temp.timestamp}).reverse().slice(0, 10);
        angular.copy(recent, $scope.temperatures);
        $scope.temp = data[0].temperature;
      });
    };

    var vURL = 'http://localhost:3000/c/'+$scope.eci+'/query/temperature_store/threshold_violations';
    $scope.getViolations = function() {
      return $http.get(vURL).success(function(data){
        angular.copy(data, $scope.violations);
      });
    };

    $scope.getAll();
    $scope.getViolations();
  }
]);