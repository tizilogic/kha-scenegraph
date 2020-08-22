package scenegraph;

import kha.FastFloat;

import scenegraph.Node;
import scenegraph.Types;
import scenegraph.Scene;


class NestedScene extends Node {
    public var scene(get, null):Scene;
    public var root(get, null):Node;

    public function new(?x:FastFloat = 0, ?y:FastFloat = 0, rect:Rect,
                        ?parent:Node = null, ?scene:Scene = null) {
        super(x, y, parent, scene);
        _scene.flags[id] |= IS_NESTED;
        _scene.insertNested(id, rect);
    }

    private inline function get_scene():Scene {
        return _scene.nested[_scene.nestedId[id]];
    }

    private inline function get_root():Node {
        return scene.root;
    }
}
