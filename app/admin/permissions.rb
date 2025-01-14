# frozen_string_literal: true

ActiveAdmin.register Permission do
  belongs_to :user

  config.filters = false

  permit_params :event_id, :action, :subject_class, :subject_id

  index download_links: false

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      f.input :subject_class, as: :select, collection: Permission::CLASSES
      f.input :action, as: :select, collection: Permission::ACTIONS
      f.input :event
      f.input :subject_id
    end
    f.actions
  end
end
