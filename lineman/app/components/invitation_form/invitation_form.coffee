angular.module('loomioApp').factory 'InvitationForm', ->
  templateUrl: 'generated/components/invitation_form/invitation_form.html'
  controller: ($scope, group, CurrentUser, AbilityService, FlashService, RestfulClient) ->
    $scope.group = group
    $scope.form = { emailAddresses: '' }
    $scope.showCustomMessageField = false
    $scope.isDisabled = false
    $scope.noInvitations = false
    remote = new RestfulClient('invitations')

    $scope.addCustomMessage = ->
      $scope.showCustomMessageField = true

    $scope.availableGroups = ->
      _.filter $scope.userGroups(), (group) ->
        AbilityService.canAddMembers(group)

    $scope.userGroups = ->
      CurrentUser.groups()

    $scope.maxInvitations = ->
      $scope.form.emailAddresses.split(' ').length > 100

    $scope.submit = ->
      $scope.isDisabled = true
      remote.create
        group_id: $scope.group.id
        email_addresses: $scope.form.emailAddresses
        message: $scope.form.message
      .then (response) ->
        invitationCount = response.data.invitations.length
        switch invitationCount
          when 0
            $scope.noInvitations = true
          when 1
            FlashService.success 'invitation_form.messages.invitation_sent'
            $scope.$close()
          else
            FlashService.success 'invitation_form.messages.invitations_sent', count: invitationCount
            $scope.$close()
      .finally ->
        $scope.isDisabled = false

    return
