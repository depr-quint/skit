require 'sketchup.rb'

module Skit
  # Line Tool
  module LineTools
    class JoinTool
      def onCancel(reason, view)
        @first_edge = nil
        view.invalidate
      end

      def onMouseMove(flags, x, y, view)
        ph = view.pick_helper
        ph.do_pick x, y
        edge = ph.picked_edge

        model = Sketchup.active_model
        model.selection.clear

        if @first_edge.nil?
          # Select picked edge if not nil.
          model.selection.add(edge) unless edge.nil?
        elsif @first_edge.valid?
          model.selection.add(@first_edge)
          # Select picked edge if not nil and
          # connected to first edge with the same direction.
          unless edge.nil?
            if connected(@first_edge, edge) && same_direction(@first_edge, edge)
              model.selection.add(edge)
            end
          end
        end
        view.invalidate
      end

      def onLButtonDown(flags, x, y, view)
        ph = view.pick_helper
        ph.do_pick x, y
        edge = ph.picked_edge

        if @first_edge.nil?
          @first_edge = edge unless edge.nil?
        elsif !edge.nil? && @first_edge.valid?
          unless connected(@first_edge, edge).nil?
            if @first_edge != edge && same_direction(@first_edge, edge)
              join(@first_edge, edge)
            end
          end
        end
        view.invalidate
      end

      private

      def join(edge1, edge2)
        model = Sketchup.active_model

        # Create new edge.
        vertex = connected(edge1, edge2)
        point1 = edge1.other_vertex(vertex).position
        point2 = edge2.other_vertex(vertex).position
        @first_edge = model.entities.add_line(point1, point2)

        # Remake faces.
        @first_edge.find_faces

        # Erase old edges.
        model.entities.erase_entities(edge1, edge2)
      end

      def connected(edge1, edge2)
        edge1.vertices.each do |vertex|
          return vertex if edge2.used_by?(vertex)
        end
        nil
      end

      def same_direction(edge1, edge2)
        edge1.line[1] == edge2.line[1] || edge1.line[1] == edge2.line[1].reverse
      end
    end

    def self.join
      Sketchup.active_model.select_tool JoinTool.new
    end
  end
end
