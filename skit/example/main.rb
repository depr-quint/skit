require 'sketchup.rb'

module Skit
  # Example Extension
  module Example
    # Creates a cube at origin.
    def self.create
      model = Sketchup.active_model
      model.start_operation('Create Cube', true)
      group = model.active_entities.add_group
      entities = group.entities
      points = [
        Geom::Point3d.new(0, 0, 0),
        Geom::Point3d.new(1.m, 0, 0),
        Geom::Point3d.new(1.m, 1.m, 0),
        Geom::Point3d.new(0, 1.m, 0)
      ]
      face = entities.add_face(points)
      face.pushpull(-1.m)
      model.commit_operation
    end
  end
end
