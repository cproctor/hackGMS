angular.module("hackGMS", [])

.controller("hackGMSController", ['$http', '$scope', function($http, $scope) {

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

}])
.directive("gmsMessage", function() {
    return {
        templateUrl: "static/templates/message.html"
    }
})
