# frozen_string_literal: true

require 'rails_helper'

describe 'Create Email/Password' do
  let_it_be(:user) { create(:user) }
  let_it_be(:doorkeeper_application) { create(:doorkeeper_application) }
  context 'with valid params for user' do
    let!(:params) do
      {
        email: user.email,
        client_id: doorkeeper_application.uid,
        client_secret: doorkeeper_application.secret
      }
    end

    it 'sends an email then returns an information message' do
      post user_password_url, params: params
      expect(status).to eq(200)
      expect(Devise.mailer.deliveries.count).to eq(1)
      expect(json['message']).to eq(I18n.t('devise.passwords.send_instructions'))
    end
  end

  context 'with invalid params for user' do
    let!(:invalid_params) do
      {
        email: user.email,
        client_id: 'invalid',
        client_secret: doorkeeper_application.secret
      }
    end

    it 'returns errors if oauth client secret is invalid' do
      post user_password_url, params: invalid_params
      expect(status).to eq(401)
      expect(Devise.mailer.deliveries.count).to eq(0)
      expect(json['errors']).to eq([I18n.t('doorkeeper.errors.messages.invalid_client')])
    end
  end

  context 'with invalid email for user' do
    let!(:invalid_email_params) do
      {
        email: 'not@registered.com',
        client_id: doorkeeper_application.uid,
        client_secret: doorkeeper_application.secret
      }
    end

    it 'does not send an email then returns errors if email was not found' do
      post user_password_url, params: invalid_email_params
      expect(status).to eq(422)
      expect(Devise.mailer.deliveries.count).to eq(0)
      expect(json['errors']).to eq(['Email not found'])
    end
  end
end
