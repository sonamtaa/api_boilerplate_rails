# frozen_string_literal: true

class Posts < ApplicationContract
  params do
    required(:id).filled(:string)
  end
end
