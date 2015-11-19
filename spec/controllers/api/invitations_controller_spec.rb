require 'rails_helper'
describe API::InvitationsController do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:contact) { create :contact, user: user }
  let(:another_group) { create :group }
  let(:another_group_member) { create :user }
  let(:group) { create :group }
  let(:pending_invitation) { create :invitation, invitable: group }

  before do
    stub_request(:post, "http://localhost:9292/faye").to_return(status: 200)
    group.admins << user
    another_group.users << user
    another_group.users << another_user
    another_group.users << another_group_member
    pending_invitation
    sign_in user
  end

  describe 'create' do
    context 'success' do

      it 'creates invitations with custom message', focus: true do
        post :create, { group_id: group.id,
                        email_addresses: 'hannah@example.com',
                        message: 'Please make decisions with us!' }
        json = JSON.parse(response.body)
        invitation = json['invitations'].first
        last_email = ActionMailer::Base.deliveries.last
        expect(invitation['recipient_email']).to eq 'hannah@example.com'
        expect(last_email).to have_body_text 'Please make decisions with us!'
        expect(last_email).to deliver_to 'hannah@example.com'
      end

      # test default message is present when no custom message
      # test garbage with email addresses
      # test multiple emails
      # test limited to 100 emails
    end

    # context 'failure' do
    #   it 'does not allow access to an unauthorized group' do
    #     cant_see_me = create :group
    #     expect { post :create, group_id: cant_see_me.id, invitations: [contact_invitable], format: :json }.to raise_error CanCan::AccessDenied
    #   end
    # end
  end

  describe 'pending' do
    context 'permitted' do
      it 'returns invitations filtered by group' do
        get :pending, group_id: group.id
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[invitations])
        expect(json['invitations'].first['id']).to eq pending_invitation.id
      end
    end

    context 'not permitted' do
      it 'returns AccessDenied' do
        sign_out user
        sign_in another_user
        get :pending, group_id: group.id
        expect(JSON.parse(response.body)['exception']).to eq 'CanCan::AccessDenied'
        expect(response.status).to eq 403
      end
    end
  end
end
