angular.module('loomioApp').factory 'InvitationForm', ->
  templateUrl: 'generated/components/invitation_form/invitation_form.html'
  controller: ($scope, group, CurrentUser, AbilityService, FlashService, RestfulClient) ->
    $scope.group = group
    $scope.form = {}
    $scope.showCustomMessageField = false
    remote = new RestfulClient('invitations')

    $scope.addCustomMessage = ->
      $scope.showCustomMessageField = true

    $scope.availableGroups = ->
      _.filter $scope.userGroups(), (group) ->
        AbilityService.canAddMembers(group)

    $scope.userGroups = ->
      CurrentUser.groups()

    $scope.submit = ->
      remote.create
        group_id: $scope.group.id
        email_addresses: $scope.form.emailAddresses
        message: $scope.form.message

    return
