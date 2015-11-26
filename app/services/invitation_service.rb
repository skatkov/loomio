class InvitationService

  def self.create_invite_to_start_group(args)
    args[:to_be_admin] = true
    args[:intent] = 'start_group'
    args[:invitable] = args[:group]
    args.delete(:group)
    Invitation.create(args)
  end

  def self.create_invite_to_join_group(args)
    args[:to_be_admin] = false
    args[:intent] = 'join_group'
    args[:invitable] = args[:group]
    args.delete(:group)
    Invitation.create(args)
  end

  def self.invite_to_group(recipient_emails: nil,
                           message: nil,
                           group: nil,
                           inviter: nil)
    recipient_emails.map do |recipient_email|
      invitation = create_invite_to_join_group(recipient_email: recipient_email,
                                               group: group,
                                               inviter: inviter)
      InvitePeopleMailer.delay.to_join_group(invitation, inviter, message)
      invitation
    end
  end

  def self.cancel(invitation:, actor:)
    actor.ability.authorize! :cancel, invitation
    invitation.cancel!(canceller: actor)
  end

  def self.redeem(invitation, user)
    if invitation.cancelled?
      raise Invitation::InvitationCancelled
    end

    if invitation.accepted?
      raise Invitation::InvitationAlreadyUsed
    end

    if invitation.single_use?
      invitation.accepted_at = DateTime.now
    end

    if invitation.to_be_admin?
      membership = invitation.group.add_admin!(user, invitation.inviter)
    else
      membership = invitation.group.add_member!(user, invitation.inviter)
    end
    invitation.save!
    Events::InvitationAccepted.publish!(membership)
  end
end
