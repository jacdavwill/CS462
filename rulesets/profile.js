angular.module('profile', [])
.controller('MainCtrl', ['$scope','$http',
  function($scope,$http){
    $scope.eci = "cklyj9kt4000gqsuwgduc44rk";
    $scope.profile = {};
    $scope.newProfile = {};

    var gURL = 'http://localhost:3000/c/'+$scope.eci+'/query/sensor_profile/profile';
    $scope.getProfile = function() {
      return $http.get(gURL).success(function(data){
        angular.copy(data, $scope.profile);
      });
    };

    var pURL = 'http://localhost:3000/sky/event/'+$scope.eci+'/temp/sensor/profile_updated';
    $scope.updateProfile = function() {
      return $http.post(pURL, $scope.newProfile).success(function(data){
        angular.copy(data, $scope.violations);
        $scope.getProfile();
      });
    };

    $scope.getProfile();
  }
]);