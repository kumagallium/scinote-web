# frozen_string_literal: true

require 'rails_helper'

describe AccessPermissions::ExperimentsController, type: :controller do
  login_user

  let!(:user) { subject.current_user }
  let!(:team) { create :team, created_by: user }
  let!(:user_team) { create :user_team, :admin, user: user, team: team }
  let!(:project) { create :project, team: team, created_by: user }
  let!(:experiment) { create :experiment, project: project }
  let!(:owner_role) { create :owner_role }
  let!(:viewer_user_role) { create :viewer_role }
  let!(:technician_role) { create :technician_role }
  let!(:user_project) { create :user_project, user: user, project: project }
  let!(:user_assignment) do
    create :user_assignment,
           assignable: project,
           user: user,
           user_role: owner_role,
           assigned_by: user
  end
  let!(:viewer_user) { create :user, confirmed_at: Time.zone.now }
  let!(:normal_user_team) { create :user_team, :normal_user, user: viewer_user, team: team }
  let!(:viewer_user_project) { create :user_project, user: viewer_user, project: project }

  describe 'GET #show' do
    it 'returns a http success response' do
      get :show, params: { project_id: project.id, id: experiment.id }, format: :json
      expect(response).to have_http_status :success
    end

    it 'renders show template' do
      get :show, params: { project_id: project.id, id: experiment.id }, format: :json
      expect(response).to render_template :show
    end
  end

  describe 'GET #edit' do
    it 'returns a http success response' do
      get :edit, params: { project_id: project.id, id: experiment.id }, format: :json
      expect(response).to have_http_status :success
    end

    it 'renders edit template' do
      get :edit, params: { project_id: project.id, id: experiment.id }, format: :json
      expect(response).to render_template :edit
    end

    it 'renders 403 if user does not have manage permissions on project' do
      create :user_assignment,
             assignable: experiment,
             user: viewer_user,
             user_role: viewer_user_role,
             assigned_by: user

      sign_in_viewer_user

      get :edit, params: { project_id: project.id, id: experiment.id }, format: :json
      expect(response).to have_http_status :forbidden
    end
  end

  describe 'PUT #update' do
    let!(:viewer_project_assignment) do
      create :user_assignment,
             assignable: project,
             user: viewer_user,
             user_role: viewer_user_role,
             assigned_by: user
    end
    let!(:viewer_user_assignment) do
      create :user_assignment,
             assignable: experiment,
             user: viewer_user,
             user_role: viewer_user_role,
             assigned_by: user
    end

    let(:valid_params) do
      {
        id: experiment.id,
        project_id: project.id,
        experiment_member: {
          user_role_id: technician_role.id,
          user_id: viewer_user.id
        }
      }
    end

    it 'updates the user role' do
      put :update, params: valid_params, format: :json
      expect(response).to have_http_status :success
      expect(viewer_user_assignment.reload.user_role).to eq technician_role
    end

    it 'does not update the user role when the user has no permissions' do
      sign_in_viewer_user

      put :update, params: valid_params, format: :json

      expect(response).to have_http_status :forbidden
      expect(viewer_user_assignment.reload.user_role).to eq viewer_user_role
    end
  end

  def sign_in_viewer_user
    sign_out user
    sign_in viewer_user
  end
end
