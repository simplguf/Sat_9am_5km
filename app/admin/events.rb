# frozen_string_literal: true

ActiveAdmin.register Event do
  menu priority: 2
  actions :all, except: :destroy

  config.sort_order = 'visible_order'

  permit_params :description, :active, :place, :name, :main_picture_link, :code_name, :town, :visible_order, :slogan

  filter :active
  filter :code_name
  filter :name
  filter :town
  filter :place

  index download_links: false do
    column :visible_order
    column :active
    column :code_name
    column :name
    column :town
    column :place
    column :slogan
    column :created_at
    actions
  end

  sidebar 'Инструкция', only: %i[new edit] do
    li 'Кодовое имя должно состоять из маленьких латинских букв, можно использовать символ "_". Для паркрановских локаций
    крайне желательно использовать то же самое имя, что было. Например, angarskieprudy - Ангарские Пруды.'
    li 'В поле Местонахождение должно быть описание как найти мероприятие. Этот текст появится в блоке Как нас найти?
    на странице мероприятия. Желательно добавить 2-4 предложения.'
    li 'Ссылка на баннер может быть как в виде url на внешнюю картинку, так и в виде указания относительного пути в ассетах.
    Крайне желательно использовать формат jpg и привести к размеру 1280х482 пикселя.'
    li 'В поле Девиз прописывается короткое ёмкое описание мероприятия, которое будет отображаться на главной странице.'
  end

  sidebar 'Управление контактами', only: %i[show edit] do
    ul do
      li link_to 'Контакты', admin_event_contacts_path(resource)
    end
  end
end
