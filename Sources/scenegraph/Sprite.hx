package scenegraph;

import kha.FastFloat;
import kha.Image;
import scenegraph.Scene;
import scenegraph.Node;
import scenegraph.Types;


class Sprite extends Node {
    public var image(get, set):Image;
    public var rect(get, set):SourceRect;

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
        return _scene.image[_scene.imageId[id]];
    }

    private inline function get_rect():SourceRect {
        return {sx:_scene.sx[id], sy:_scene.sy[id], sw:_scene.sw[id], sh:_scene.sh[id]};
    }

    private inline function set_rect(v:SourceRect):SourceRect {
        _scene.sx[id] = v.sx;
        _scene.sy[id] = v.sy;
        _scene.sw[id] = v.sw;
        _scene.sh[id] = v.sh;
        _scene.propagateDirty(id);
        return v;
    }

    private override function set_width(v:FastFloat):FastFloat {
        throw "Cannot set width of Sprite";
    }

    private override function set_height(v:FastFloat):FastFloat {
        throw "Cannot set height of Sprite";
    }
}
