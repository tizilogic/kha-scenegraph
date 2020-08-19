package scenegraph;

import kha.Color;
import kha.FastFloat;
import kha.Image;
import scenegraph.Scene;
import scenegraph.Node;
import scenegraph.Types;


class Sprite extends Node {
    public var image(get, set):Image;
    public var sx(get, set):FastFloat;
    public var sy(get, set):FastFloat;
    public var sw(get, set):FastFloat;
    public var sh(get, set):FastFloat;
    public var color(get, set):Color;

    public function new(?x:FastFloat = 0, ?y:FastFloat = 0, image:Image, ?rect:SourceRect = null,
                        ?parent:Node = null, ?scene:Scene = null) {
        super(x, y, parent, scene);
        _scene.flags[id] = _scene.flags[id] | IS_IMAGE;
        _scene.insertImage(id, image, rect);
    }

    private inline function get_image():Image {
        return _scene.image[_scene.imageId[id]];
    }

    private inline function set_image(v:Image):Image {
        _scene.image[_scene.imageId[id]] = v;
        _scene.propagateDirty(id);
        return _scene.image[_scene.imageId[id]];
    }

    private inline function get_sx():FastFloat {
        return _scene.sx[id];
    }

    private inline function set_sx(v:FastFloat):FastFloat {
        _scene.sx[_scene.imageId[id]] = v;
        _scene.propagateDirty(id);
        return v;
    }

    private inline function get_sy():FastFloat {
        return _scene.sy[id];
    }

    private inline function set_sy(v:FastFloat):FastFloat {
        _scene.sy[_scene.imageId[id]] = v;
        _scene.propagateDirty(id);
        return v;
    }

    private inline function get_sw():FastFloat {
        return _scene.sw[id];
    }

    private inline function set_sw(v:FastFloat):FastFloat {
        _scene.sw[_scene.imageId[id]] = v;
        _scene.propagateDirty(id);
        return v;
    }

    private inline function get_sh():FastFloat {
        return _scene.sh[id];
    }

    private inline function set_sh(v:FastFloat):FastFloat {
        _scene.sh[_scene.imageId[id]] = v;
        _scene.propagateDirty(id);
        return v;
    }

    private inline function get_color():Color {
        return _scene.spriteColor[_scene.imageId[id]];
    }

    private inline function set_color(v:Color):Color {
        if (v == null && _scene.flags[id] & HAS_COLOR > 0) {
            _scene.flags[id] ^= HAS_COLOR;
        }
        else if (v != null && _scene.flags[id] & HAS_COLOR == 0) {
            _scene.flags[id] |= HAS_COLOR;
        }
        _scene.spriteColor[_scene.imageId[id]] = v;
        _scene.propagateDirty(id);
        return _scene.spriteColor[_scene.imageId[id]];
    }

    private override function set_width(v:FastFloat):FastFloat {
        throw "Cannot set width of Sprite";
    }

    private override function set_height(v:FastFloat):FastFloat {
        throw "Cannot set height of Sprite";
    }
}
