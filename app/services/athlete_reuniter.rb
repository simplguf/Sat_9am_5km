# frozen_string_literal: true

class AthleteReuniter < ApplicationService
  SKIPPED_ATTRIBUTES = %w[id created_at updated_at name].freeze
  MODIFIED_ATTRIBUTES = %w[parkrun_code fiveverst_code user_id club_id male].freeze
  private_constant :SKIPPED_ATTRIBUTES, :MODIFIED_ATTRIBUTES

  def initialize(collection, ids)
    @collection = collection
    @ids = ids
  end

  def call
    return false unless athlete

    grab_modified_attributes_from_collection
    grab_volunteering_count_from_collection
    check_modified_fields
    replace_all_by_one and return true
  rescue StandardError => e
    Rails.logger.error e.inspect
    false
  end

  private

  attr_reader :collection, :ids

  def athlete
    @athlete ||= collection.where.not(name: nil).take
  end

  def grab_volunteering_count_from_collection
    athlete.volunteering_count = collection.sum(:volunteering_count)
    unmodified_attributes.delete('volunteering_count')
  end

  def grab_modified_attributes_from_collection
    MODIFIED_ATTRIBUTES.each do |attr|
      athlete.public_send "#{attr}=", athlete.send(attr) || collection.where.not(attr => nil).take&.send(attr)
      unmodified_attributes.delete(attr)
    end
  end

  def unmodified_attributes
    @unmodified_attributes ||= athlete.attribute_names - SKIPPED_ATTRIBUTES
  end

  def check_modified_fields
    return if unmodified_attributes.empty?

    message = "AthleteReuniter skips modification of public attribute(s): #{unmodified_attributes}"
    raise StandardError, message if Rails.env.test?

    Rails.logger.warn message
  end

  def replace_all_by_one
    ActiveRecord::Base.transaction do
      # rubocop:disable Rails/SkipsModelValidations
      Result.where(athlete_id: ids).update_all(athlete_id: athlete.id)
      Volunteer.where(athlete_id: ids).update_all(athlete_id: athlete.id)
      Trophy.where(athlete_id: ids).update_all(athlete_id: athlete.id)
      collection.where.not(id: athlete.id).destroy_all
      athlete.save!
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end
