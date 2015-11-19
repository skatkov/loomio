angular.module('loomioApp').factory 'InvitationForm', ->
  templateUrl: 'generated/components/invitation_form/invitation_form.html'
  controller: ($scope, group, Records, CurrentUser, AbilityService, FlashService) ->
    $scope.group = group
    $scope.invitations = []
    $scope.showCustomMessageField = false

    $scope.addCustomMessage = ->
      $scope.showCustomMessageField = true

    $scope.availableGroups = ->
      _.filter $scope.userGroups(), (group) ->
        AbilityService.canAddMembers(group)

    $scope.userGroups = ->
      CurrentUser.groups()

    $scope.submit = ->
      

    return
