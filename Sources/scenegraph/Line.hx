package scenegraph;

import kha.Color;
import kha.FastFloat;

import scenegraph.Node;
import scenegraph.Types;
import scenegraph.Scene;


class Line extends Node {
    public var color(get, set):Color;
    public var strength(get, set):FastFloat;
    public var x1(get, set):FastFloat;
    public var y1(get, set):FastFloat;
    public var x2(get, set):FastFloat;
    public var y2(get, set):FastFloat;

    public function new(x1:FastFloat, y1:FastFloat, x2:FastFloat, y2:FastFloat, color:Color, ?strength:FastFloat = 0, ?parent:Node = null, ?scene:Scene = null, ?name:String = null) {
        var left:FastFloat = Math.min(x1, x2);
        var right:FastFloat = Math.max(x1, x2);
        var top:FastFloat = Math.min(y1, y2);
        var bottom:FastFloat = Math.max(y1, y2);
        super(0, 0, parent, scene, name);
        _xGetter = xGetter;
        _xSetter = xSetter;
        _yGetter = yGetter;
        _ySetter = ySetter;
        _scene.flags[id] |= IS_LINE;
        _scene.insertLine(id, x1, y1, x2, y2, color, strength);
        _scene.width[id] = right - left;
        _scene.height[id] = bottom - top;
    }

    private inline function xGetter():FastFloat {
        return Math.min(x1, x2);
    }

    private inline function xSetter(v:FastFloat):FastFloat {
        var d = v - xGetter();
        x1 += d;
        x2 += d;
        return v;
    }

    private inline function yGetter():FastFloat {
        return Math.min(y1, y2);
    }

    private inline function ySetter(v:FastFloat):FastFloat {
        var d = v - yGetter();
        y1 += d;
        y2 += d;
        return v;
    }

    private inline function get_color():Color {
        return _scene.lineColor[_scene.lineId[id]];
    }

    private inline function set_color(v:Color):Color {
        _scene.propagateDirty(id);
        return _scene.lineColor[_scene.lineId[id]] = v;
    }

    private inline function get_strength():FastFloat {
        return _scene.lineStrength[_scene.lineId[id]];
    }

    private inline function set_strength(v:FastFloat):FastFloat {
        _scene.propagateDirty(id);
        return _scene.lineStrength[_scene.lineId[id]] = v;
    }

    private inline function get_x1():FastFloat {
        return _scene.lineX1[_scene.lineId[id]];
    }

    private inline function set_x1(v:FastFloat):FastFloat {
        _scene.propagateDirty(id);
        return _scene.lineX1[_scene.lineId[id]] = v;
    }

    private inline function get_y1():FastFloat {
        return _scene.lineY1[_scene.lineId[id]];
    }

    private inline function set_y1(v:FastFloat):FastFloat {
        _scene.propagateDirty(id);
        return _scene.lineY1[_scene.lineId[id]] = v;
    }

    private inline function get_x2():FastFloat {
        return _scene.lineX2[_scene.lineId[id]];
    }

    private inline function set_x2(v:FastFloat):FastFloat {
        _scene.propagateDirty(id);
        return _scene.lineX2[_scene.lineId[id]] = v;
    }

    private inline function get_y2():FastFloat {
        return _scene.lineY2[_scene.lineId[id]];
    }

    private inline function set_y2(v:FastFloat):FastFloat {
        _scene.propagateDirty(id);
        return _scene.lineY2[_scene.lineId[id]] = v;
    }
}
