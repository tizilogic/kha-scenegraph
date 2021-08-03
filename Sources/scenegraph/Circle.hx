package scenegraph;

import kha.Color;
import kha.FastFloat;

import scenegraph.Node;
import scenegraph.Types;
import scenegraph.Scene;


class Circle extends Node {
    public var color(get, set):Color;
    public var borderColor(get, set):Color;
    public var border(get, set):FastFloat;
    public var radius(get, set):FastFloat;

    public function new(?x:FastFloat = 0, ?y:FastFloat = 0, radius:FastFloat, color:Color, ?border:FastFloat = 0, ?borderColor:Color = null, ?parent:Node = null, ?scene:Scene = null, ?name:String = null) {
        super(x, y, parent, scene, name);
        _scene.flags[id] |= IS_CIRCLE;
        _scene.insertCircle(id, radius, color, border, borderColor);
        _scene.width[id] = radius * 2;
        _scene.height[id] = radius * 2;
    }

    private inline function get_color():Color {
        return _scene.circleColor[_scene.circleId[id]];
    }

    private inline function set_color(v:Color):Color {
        _scene.propagateDirty(id);
        return _scene.circleColor[_scene.circleId[id]] = v;
    }

    private inline function get_borderColor():Color {
        return _scene.circleBorderColor[_scene.circleId[id]];
    }

    private inline function set_borderColor(v:Color):Color {
        _scene.propagateDirty(id);
        return _scene.circleBorderColor[_scene.circleId[id]] = v;
    }

    private inline function get_border():FastFloat {
        return _scene.circleBorder[_scene.circleId[id]];
    }

    private inline function set_border(v:FastFloat):FastFloat {
        return _scene.circleBorder[_scene.circleId[id]] = v;
    }

    private inline function get_radius():FastFloat {
        return _scene.circleRadius[_scene.circleId[id]];
    }

    private inline function set_radius(v:FastFloat):FastFloat {
        return _scene.circleRadius[_scene.circleId[id]] = v;
    }
}
