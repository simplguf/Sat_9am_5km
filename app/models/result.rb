# frozen_string_literal: true

class Result < ApplicationRecord
  belongs_to :activity
  belongs_to :athlete, optional: true

  enum role: { runner: 0, volunteer: 1 }
end