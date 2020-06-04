class AddIndexToWantedlyProjectsStatus < ActiveRecord::Migration[6.0]
  def change
    add_index :wantedly_projects, :status
  end
end
