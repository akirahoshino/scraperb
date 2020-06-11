class CreateWantedlyProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :wantedly_projects do |t|
      t.string    :url, null: false
      t.string    :title
      t.integer   :status, null: false
      t.date      :posted_at
      t.string    :company_name
      t.text      :company_info
      t.text      :company_address
      t.float     :latitude
      t.float     :longitude
      t.text      :body
      t.timestamps
      t.index     :latitude
      t.index     :longitude
    end
  end
end
