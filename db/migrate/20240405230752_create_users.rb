class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :fio
      t.string :email
      t.string :password
      t.boolean :teacher
      t.string :jwt_validation

      t.timestamps
    end
  end
end
