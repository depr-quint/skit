require 'sketchup.rb'

module Skit
  # Connect Tool
  module ConnectTool

    # Joins the endpoints of linear edges to create a single edge.
    def self.join
      model = Sketchup.active_model
      return if model.selection.empty?

      selection = model.selection.to_a
      selection.each_with_index do |edge1, i|
        next unless edge1.is_a? Sketchup::Edge

        selection.each_with_index do |edge2, j|
          next unless edge2.is_a? Sketchup::Edge
          next if edge1 == edge2 || j <= i

          vertex = connected(edge1, edge2)
          next if vertex.nil?

          # Check if edges have same direction.
          unless edge1.line[1] == edge2.line[1] || edge1.line[1] == edge2.line[1].reverse
            next
          end

          # Can not remove vertex at junction.
          if vertex.edges.length != 2
            UI.messagebox('Vertex is used by more than two edges.')
            next
          end

          # Create new edge.
          point1 = edge1.other_vertex(vertex).position
          point2 = edge2.other_vertex(vertex).position
          edge = model.entities.add_line(point1, point2)

          # Remake faces.
          edge.find_faces

          # Erase old edges.
          model.entities.erase_entities(edge1, edge2)
          return
        end
      end
    end

    def self.connected(edge1, edge2)
      edge1.vertices.each do |vertex|
        return vertex if edge2.used_by? vertex
      end
    end
  end
end
