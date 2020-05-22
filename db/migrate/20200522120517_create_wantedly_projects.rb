class CreateWantedlyProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :wantedly_projects do |t|
      t.text      :url
      t.string    :title
      t.interger  :status
      t.date      :posted_at
      t.string    :company_name
      t.text      :company_info
      t.text      :company_address
      t.string    :map_center
      t.text      :body
      t.timestamps
    end
  end
end
