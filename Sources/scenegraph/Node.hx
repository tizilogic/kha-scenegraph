package scenegraph;


import kha.FastFloat;
import kha.Image;
import kha.graphics2.Graphics;
import kha.math.FastMatrix3;
import scenegraph.Types;
import scenegraph.Scene;


class Node {
    private var _scene:Scene;

    public var id(get, null):Int;
    public var x(get, set):FastFloat;
    public var y(get, set):FastFloat;
    public var depth(get, set):Int;
    public var alpha(get, set):FastFloat;
    public var angle(get, set):FastFloat;
    public var shown(get, set):Bool;

    public function new(?x:FastFloat = 0, ?y:FastFloat = 0, ?parent:Node = null, ?scene:Scene = null,
                        ?_root:Bool = false) {
        if (scene == null) {
            _scene = Scene.defaultInstance();
        }
        else {
            _scene = scene;
        }
        if (_root) {
            this.id = 0;
            return;
        }
        this.id = _scene.newNode();
        this.x = x;
        this.y = y;
        this.shown = true;
    }

    public static function fromId(id:Int, ?scene:Scene = null):Node {
        scene = scene == null ? Scene.defaultInstance() : scene;
        if (!Scene.nodes.exists(scene) || !Scene.nodes[scene].exists(id)) {
            throw "Invalid node id";
        }
        return Scene.nodes[scene][id];
    }

    public function destroy() {
        _scene.removeNode(id);
    }

    public function reparentTo(parent:Node) {
        if (_scene != parent._scene) {
            throw "reparenting across multiple scenes not implemented";
        }
        _scene.parent[id] = parent.id;
        _scene.propagateDirty(id);
    }

    // Getter/Setter
    private inline function get_id():Int {
        return id;
    }

    private inline function get_x():FastFloat {
        return _scene.x[id];
    }

    private inline function set_x(v:FastFloat):FastFloat {
        _scene.x[id] = v;
        _scene.propagateDirty(id);
        return _scene.x[id];
    }

    private inline function get_y():FastFloat {
        return _scene.y[id];
    }

    private inline function set_y(v:FastFloat):FastFloat {
        _scene.y[id] = v;
        _scene.propagateDirty(id);
        return _scene.y[id];
    }

    private inline function get_depth():Int {
        return _scene.depth[id];
    }

    private inline function set_depth(v:Int):Int {
        _scene.depth[id] = v;
        _scene.propagateDirty(id);
        return _scene.depth[id];
    }

    private inline function get_alpha():FastFloat {
        return _scene.alpha[id];
    }

    private inline function set_alpha(v:FastFloat):FastFloat {
        _scene.alpha[id] = v;
        _scene.propagateDirty(id);
        return _scene.alpha[id];
    }

    private inline function get_angle():FastFloat {
        return _scene.angle[id];
    }

    private inline function set_angle(v:FastFloat):FastFloat {
        _scene.angle[id] = v;
        _scene.propagateDirty(id);
        return _scene.angle[id];
    }

    private inline function get_shown():Bool {
        return _scene.flags[id] & HIDDEN == 0;
    }

    private inline function set_shown(v:Bool):Bool {
        if (v && _scene.flags[id] & HIDDEN > 0) {
            _scene.flags[id] = _scene.flags[id] ^ HIDDEN;
            _scene.propagateDirty(id);
        }
        else if (!v && _scene.flags[id] & HIDDEN == 0) {
            _scene.flags[id] = _scene.flags[id] | HIDDEN;
            _scene.propagateDirty(id);
        }
        return _scene.flags[id] & HIDDEN == 0;
    }
}
