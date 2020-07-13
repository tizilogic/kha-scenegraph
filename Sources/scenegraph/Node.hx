package scenegraph;


import kha.Color;
import kha.FastFloat;
import kha.Font;
import kha.Image;
import scenegraph.Scene;
import scenegraph.Sprite;
import scenegraph.Text;
import scenegraph.Types;


class Node {
    private var _scene:Scene;

    public var id(get, null):Int;
    public var x(get, set):FastFloat;
    public var y(get, set):FastFloat;
    public var scale(null, set):FastFloat;
    public var scaleX(get, set):FastFloat;
    public var scaleY(get, set):FastFloat;
    public var depth(get, set):Int;
    public var alpha(get, set):FastFloat;
    public var angle(get, set):FastFloat;
    public var shown(get, set):Bool;
    public var width(get, set):FastFloat;
    public var height(get, set):FastFloat;

    public function new(?x:FastFloat = 0, ?y:FastFloat = 0, ?parent:Node = null, ?scene:Scene = null,
                        ?_root:Bool = false) {
        if (scene == null && parent == null) {
            _scene = Scene.defaultInstance();
        }
        else if (parent != null) {
            _scene = parent._scene;
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
        if (parent != null) {
            reparentTo(parent);
        }
        else {
            _scene.propagateDirty(this.id);
        }
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

    public function attachNode():Node {
        return new Node(this);
    }

    public function attachSprite(image:Image, ?rect:SourceRect = null):Sprite {
        return new Sprite(image, rect, this);
    }

    public function attachText(?text:String = "", font:Font, fontSize:FastFloat,
                               ?color:Color = Color.White):Text {
        return new Text(text, font, fontSize, color, this);
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

    private inline function set_scale(v:FastFloat):FastFloat {
        _scene.scaleX[id] = v;
        _scene.scaleY[id] = v;
        _scene.propagateDirty(id);
        return _scene.scaleX[id];
    }

    private inline function get_scaleX():FastFloat {
        return _scene.scaleX[id];
    }

    private inline function set_scaleX(v:FastFloat):FastFloat {
        _scene.scaleX[id] = v;
        _scene.propagateDirty(id);
        return _scene.scaleX[id];
    }

    private inline function get_scaleY():FastFloat {
        return _scene.scaleY[id];
    }

    private inline function set_scaleY(v:FastFloat):FastFloat {
        _scene.scaleY[id] = v;
        _scene.propagateDirty(id);
        return _scene.scaleY[id];
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

    private inline function get_width():FastFloat {
        return _scene.width[id];
    }

    private function set_width(v:FastFloat):FastFloat {
        _scene.width[id] = v;
        return _scene.width[id];
    }

    private inline function get_height():FastFloat {
        return _scene.height[id];
    }

    private function set_height(v:FastFloat):FastFloat {
        _scene.height[id] = v;
        return _scene.height[id];
    }
}
