require 'sketchup.rb'

module Skit
  # Line Tool
  module LineTools

    # Joins the endpoints of linear edges to create a single edge.
    def self.join
      model = Sketchup.active_model
      return if model.selection.empty?

      selection = model.selection.grep(Sketchup::Edge).to_a
      selection.each_with_index do |edge1, i|
        selection.each_with_index do |edge2, j|
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
          model.selection.add(edge)

          # Remake faces.
          edge.find_faces

          # Erase old edges.
          model.entities.erase_entities(edge1, edge2)
          return nil
        end
      end
    end

    def self.connect
      model = Sketchup.active_model
      return if model.selection.empty?

      selection = model.selection.to_a
      selection.each_with_index do |edge1, i|
        next unless edge1.is_a? Sketchup::Edge

        selection.each_with_index do |edge2, j|
          next unless edge2.is_a? Sketchup::Edge
          next if edge1 == edge2 || j <= i

          # Skip if have common face
          next unless edge1.common_face(edge2).nil?

          vertex = connected(edge1, edge2)
          if vertex.nil?
            # Selected edges are not adjacent.
            point1, point2 = closest_vertices(edge1, edge2)
          else
            # Selected edges share a vertex.
            point1 = edge1.other_vertex(vertex).position
            point2 = edge2.other_vertex(vertex).position
          end
          next unless !point1.nil? && !point2.nil?

          # Create new edge.
          edge = model.entities.add_line(point1, point2)
          model.selection.add(edge)

          # Remake faces.
          edge.find_faces
          return nil
        end
      end
    end

    private

    def self.connected(edge1, edge2)
      edge1.vertices.each do |vertex|
        return vertex if edge2.used_by? vertex
      end
      nil
    end

    def self.closest_vertices(edge1, edge2)
      distance = 0 # distance between two closest points.
      closest1 = nil # closest point of edge1
      count1 = 0 # count of edges adjacent
      closest2 = nil # closest point of edge2
      count2 = 0 # count of edges adjacent
      edge1.vertices.each do |vertex1|
        point1 = vertex1.position
        count1 = count_edges(vertex1) if count1.zero?
        next if count1 < count_edges(vertex1)

        edge2.vertices.each do |vertex2|
          point2 = vertex2.position
          count2 = count_edges(vertex2) if count2.zero?
          next if count2 < count_edges(vertex2)

          # Ignore if already have a common edge
          next unless vertex1.common_edge(vertex2).nil?

          distance = point1.distance(point2) if distance.zero?
          dist = point1.distance(point2)
          next unless dist <= distance

          distance = dist
          closest1 = point1
          closest2 = point2
          count1 = count_edges(vertex1)
          count2 = count_edges(vertex2)
        end
      end
      [closest1, closest2]
    end

    def self.count_edges(vertex)
      count = 0
      Sketchup.active_model.selection.grep(Sketchup::Edge) do |edge|
        count += 1 if vertex.used_by? edge
      end
      count
    end

    private_class_method :connected, :closest_vertices, :count_edges
  end
end
