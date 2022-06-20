# frozen_string_literal: true

class Activity < ApplicationRecord
  has_many :results, dependent: :destroy
  has_many :athletes, through: :results
end
