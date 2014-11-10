angular.module("hackGMS", [])

.controller("hackGMSController", ['$http', '$interval', '$scope', function($http, $interval, $scope) {

    $scope.reloadMessages = function() {
        $http.get('api/messages').then(function(response) {
            $scope.messages = response.data;
            _.each($scope.messages, function(message) {
                message.date = new Date(message.date);
            })
        });
    }

    $scope.addMessage = function() {
        var newMessageData = {
            text: $scope.messageText,
            date: new Date()
        };
        $http.post('api/messages/create', newMessageData)
            .then($scope.reloadMessages)
            .then(function() {
                $scope.messageText = "";
            });
    }

    $scope.deleteMessage = function(message) {
        $http.get('api/messages/delete/' + message.id)
            .then($scope.reloadMessages)
    }

    $scope.reloadMessages()
    $interval($scope.reloadMessages, 5000)

}])
.directive("gmsMessageDelete", function() {
    return {
        templateUrl: "static/templates/message.html"
    }
})

.directive("gmsMessageNoDelete", function() {
    return {
        templateUrl: "static/templates/messageNoDelete.html"
    }
})
