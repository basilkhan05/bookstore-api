class Author < ApplicationRecord
  has_many :books, dependent: :destroy
  has_many :published, foreign_key: :publisher_id, class_name: 'Book', as: :publisher

  def discount
    10
  end
end
