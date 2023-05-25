# frozen_string_literal: true

require 'rails_helper'

describe 'Update Password' do
  let_it_be(:user) { create(:user) }
  let_it_be(:doorkeeper_application) { create(:doorkeeper_application) }

  context 'with valid params' do
    let!(:token) { user.send_reset_password_instructions }
    let!(:params) do
      {
        reset_password_token: token,
        password: user.password,
        password_confirmation: user.password,
        client_id: doorkeeper_application.uid,
        email: user.email,
        client_secret: doorkeeper_application.secret
      }
    end

    it 'updates password' do
      patch(user_password_url, params:)
      expect(status).to eq(200)
      expect(json['message']).to eq(I18n.t('devise.passwords.updated_not_active'))
    end
  end

  context 'with invalid params for user' do
    let!(:token) { user.send_reset_password_instructions }
    let!(:invalid_params) do
      {
        reset_password_token: token,
        password: user.password,
        password_confirmation: user.password,
        client_id: 'invalid',
        email: user.email,
        client_secret: doorkeeper_application.secret
      }
    end

    it 'returns errors if oauth client id is invalid' do
      patch user_password_url, params: invalid_params
      expect(status).to eq(401)
      expect(json['errors']).to eq([I18n.t('doorkeeper.errors.messages.invalid_client')])
    end
  end

  context 'with invalid token for user' do
    before { user.send_reset_password_instructions }

    let!(:invalid_token_params) do
      {
        reset_password_token: 'so_secret_token',
        password: user.password,
        password_confirmation: user.password,
        client_id: doorkeeper_application.uid,
        email: user.email,
        client_secret: doorkeeper_application.secret
      }
    end

    it 'does not update password with invalid token' do
      patch user_password_url, params: invalid_token_params
      expect(status).to eq(422)
      expect(json['errors']).to eq(['Reset password token is invalid'])
    end
  end
end
