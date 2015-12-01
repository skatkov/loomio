class CommentService
  def self.unlike(comment:, actor:)
    return false unless comment.likers.include? actor
    actor.ability.authorize!(:unlike, comment)

    CommentVote.where(user_id: actor.id, comment_id: comment.id).destroy_all
    comment.refresh_liker_ids_and_names!

    Memos::CommentUnliked.publish!(comment: comment, user: actor)

  end

  def self.like(comment:, actor:)
    actor.ability.authorize!(:like, comment)

    comment_vote = CommentVote.find_or_create_by(comment_id: comment.id,
                                                 user_id: actor.id)

    comment.refresh_liker_ids_and_names!

    DiscussionReader.for(discussion: comment.discussion,
                         user: actor).set_volume_as_required!

    Events::CommentLiked.publish!(comment_vote)
  end

  def self.create(comment:, actor:)
    comment.author = actor
    actor.ability.authorize! :create, comment
    comment.attachment_ids = [comment.attachment_ids, comment.new_attachment_ids].compact.flatten
    return false unless comment.valid?

    comment.save!
    comment.discussion.update_attribute(:last_comment_at, comment.created_at)

    Draft.purge_without_delay(user: actor, draftable: comment.discussion, field: :comment)
    SearchVector.index! comment.discussion_id

    event = Events::NewComment.publish!(comment)
    DiscussionReader.for(user: actor, discussion: comment.discussion).author_thread_item!(comment.created_at)
    event
  end

  def self.destroy(comment:, actor:)
    actor.ability.authorize!(:destroy, comment)
    # paranoid destroy_all because comment votes seem to be dangling around.
    comment.comment_votes.destroy_all
    comment.destroy
    Memos::CommentDestroyed.publish!(comment)
  end

  def self.update(comment:, params:, actor:)
    new_mentions = Comment.new(params).mentioned_usernames - comment.mentioned_usernames

    comment.edited_at = Time.zone.now
    comment.body = params[:body]

    return false unless comment.valid?
    actor.ability.authorize! :create, comment
    SearchVector.index! comment.discussion_id
    comment.save!

    User.where(username: new_mentions).each { |user| Events::UserMentioned.publish!(comment, user) } if new_mentions.any?
    Memos::CommentUpdated.publish!(comment)
    true
  end
end
