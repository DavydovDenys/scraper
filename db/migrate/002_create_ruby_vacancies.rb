require_relative '../../ar.rb'

class CreateRubyVacancies < ActiveRecord::Migration[4.2]
  # The name of this class is derived by 
  # camel-casing the words in the filename.

  # The up method describe the ruby_vacancy table we wish to create.
  def up
    create_table :ruby_vacancies do |t|
      # An id column is automatically created.
      # This id will be an auto-incrementing
      # primary key.
      t.string :title
      t.text :description
      t.string :details
      t.string :url
      t.timestamps # Generates our updated_at and created_at columns.
    end
  end

  # The down method describes how to undo what the up method does.
  def down
    drop_table :ruby_vacancies
  end
  # self.down runs this SQL:
  # DROP TABLE "ruby_vacancies"
end





