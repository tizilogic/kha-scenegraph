package scenegraph;

import kha.Color;
import kha.FastFloat;
import SDFPainter;

import scenegraph.Node;
import scenegraph.Types;
import scenegraph.Scene;


class Tile extends Node {
    public var color(get, set):Color;
    public var borderColor(get, set):Color;
    public var border(get, set):FastFloat;
    public var tr(get, set):FastFloat;
    public var br(get, set):FastFloat;
    public var tl(get, set):FastFloat;
    public var bl(get, set):FastFloat;

    public function new(?x:FastFloat = 0, ?y:FastFloat = 0, width:FastFloat, height:FastFloat, corner:CornerRadius, color:Color, ?border:FastFloat = 0, ?borderColor:Color = null, ?parent:Node = null, ?scene:Scene = null) {
        super(x, y, parent, scene);
        _scene.flags[id] |= IS_TILE;
        _scene.insertTile(id, corner, color, border, borderColor);
        _scene.width[id] = width;
        _scene.height[id] = height;
    }

    private inline function get_color():Color {
        return _scene.tileColor[_scene.tileId[id]];
    }

    private inline function set_color(v:Color):Color {
        _scene.propagateDirty(id);
        return _scene.tileColor[_scene.tileId[id]] = v;
    }

    private inline function get_borderColor():Color {
        return _scene.tileBorderColor[_scene.tileId[id]];
    }

    private inline function set_borderColor(v:Color):Color {
        _scene.propagateDirty(id);
        return _scene.tileBorderColor[_scene.tileId[id]] = v;
    }

    private inline function get_border():FastFloat {
        return _scene.tileBorder[_scene.tileId[id]];
    }

    private inline function set_border(v:FastFloat):FastFloat {
        return _scene.tileBorder[_scene.tileId[id]] = v;
    }

    private inline function get_tr():FastFloat {
        return _scene.tileCTR[_scene.tileId[id]];
    }

    private inline function set_tr(v:FastFloat):FastFloat {
        return _scene.tileCTR[_scene.tileId[id]] = v;
    }

    private inline function get_br():FastFloat {
        return _scene.tileCBR[_scene.tileId[id]];
    }

    private inline function set_br(v:FastFloat):FastFloat {
        return _scene.tileCBR[_scene.tileId[id]] = v;
    }

    private inline function get_tl():FastFloat {
        return _scene.tileCTL[_scene.tileId[id]];
    }

    private inline function set_tl(v:FastFloat):FastFloat {
        return _scene.tileCTL[_scene.tileId[id]] = v;
    }

    private inline function get_bl():FastFloat {
        return _scene.tileCBL[_scene.tileId[id]];
    }

    private inline function set_bl(v:FastFloat):FastFloat {
        return _scene.tileCBL[_scene.tileId[id]] = v;
    }
}
