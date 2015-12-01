angular.module('loomioApp').factory 'AddMembersModal', ->
  templateUrl: 'generated/components/invitation_form/add_members_modal/add_members_modal.html'
  controller: ($scope, Records, LoadingService, group, AppConfig, FlashService) ->
    $scope.group = group
    $scope.loading = true
    $scope.selectedIds = []

    $scope.load = ->
      Records.memberships.fetchByGroup(group.parent().key)

    $scope.members = ->
      group.parent().members()

    LoadingService.applyLoadingFunction($scope, 'load')
    $scope.load()
