defmodule Wall.Repo.Migrations.AddDeployentsToWallView do
  use Ecto.Migration

  def up do
    execute """
    CREATE OR REPLACE VIEW wall AS
      SELECT DISTINCT projects.id,
          projects.name,
          first_value(e1.status) OVER (PARTITION BY e1.project_id ORDER BY e1.date DESC) AS master_build_status,
          first_value(e2.status) OVER (PARTITION BY e2.project_id ORDER BY e2.date DESC) AS latest_build_status,
          first_value(e3.date) OVER (PARTITION BY e3.project_id ORDER BY e3.date DESC) AS latest_deployment
        FROM projects
           LEFT JOIN events e1 ON projects.id = e1.project_id AND e1.subtopic::text = 'master'::text AND e1.topic::text = 'ci'::text
           LEFT JOIN events e2 ON projects.id = e2.project_id AND e2.topic::text = 'ci'::text
           LEFT JOIN events e3 ON projects.id = e3.project_id AND e3.topic::text = 'deployment'::text;
     """
  end

  def down do
    execute """
    DROP VIEW wall;
    CREATE VIEW wall AS
      SELECT DISTINCT projects.id,
          projects.name,
          first_value(e1.status) OVER (PARTITION BY e1.project_id ORDER BY e1.date DESC) AS master_build_status,
          first_value(e2.status) OVER (PARTITION BY e2.project_id ORDER BY e2.date DESC) AS latest_build_status
        FROM projects
           LEFT JOIN events e1 ON projects.id = e1.project_id AND e1.subtopic::text = 'master'::text
           LEFT JOIN events e2 ON projects.id = e2.project_id;
     """
  end
end
