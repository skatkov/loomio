module Development::DashboardHelper
  def starred_proposal_discussion
    create_discussion!(:starred_proposal_discussion) { |discussion| star!(discussion); add_proposal!(discussion) }
  end

  def proposal_discussion
    create_discussion!(:proposal_discussion) { |discussion| add_proposal!(discussion) }
  end

  def starred_discussion
    create_discussion!(:starred_discussion) { |discussion| star!(discussion) }
  end

  def participating_discussion
    create_discussion!(:participating_discussion) { |discussion| participate!(discussion) }
  end

  def recent_discussion(group: test_group)
    create_discussion!(:recent_discussion, group: group)
  end

  def old_discussion
    create_discussion!(:old_discussion) { |discussion| discussion.update last_activity_at: 2.years.ago }
  end

  def muted_discussion
    create_discussion!(:muted_discussion) { |discussion| mute!(discussion) }
  end

  def private_discussion
    create_discussion!(:private_discussion, group: private_test_group, private: true)
  end

  private

  def create_discussion!(name, group: test_group, author: patrick, private: false)
    var_name = :"@#{name}"
    if existing = instance_variable_get(var_name)
      existing
    else
      instance_variable_set(var_name, Discussion.create!(title: name.to_s.humanize, group: group, author: author, private: private).tap do |discussion|
        yield discussion if block_given?
      end)
    end
  end

  def star!(discussion, user: patrick)
    DiscussionReader.for(discussion: discussion, user: user).update starred: true
  end

  def mute!(discussion, user: patrick)
    DiscussionReader.for(discussion: discussion, user: user).update volume: DiscussionReader.volumes[:mute]
  end

  def participate!(discussion, user: patrick)
    DiscussionReader.for(discussion: discussion, user: user).participate!
  end

  def add_proposal!(discussion, name: 'Test proposal', actor: jennifer)
    MotionService.create(motion: Motion.new(name: name, closing_at: 3.days.from_now, discussion: discussion), actor: actor)
  end

end
