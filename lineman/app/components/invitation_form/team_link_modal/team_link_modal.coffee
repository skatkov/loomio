angular.module('loomioApp').factory 'TeamLinkModal', ->
  templateUrl: 'generated/components/invitation_form/team_link_modal/team_link_modal.html'
  controller: ($scope, group) ->
    $scope.group = group