class AddSingleUseAttributeToInvitations < ActiveRecord::Migration
  def change
    add_column    :invitations, :single_use, :boolean, default: true, null: false
    remove_column :invitations, :accepted_by_id
  end
end
