package scenegraph;


import kha.Color;
import kha.FastFloat;
import kha.math.FastVector2;
import kha.Font;
import kha.Image;
import SDFPainter;

import scenegraph.FmtText;
import scenegraph.NestedScene;
import scenegraph.Scene;
import scenegraph.Sprite;
import scenegraph.Text;
import scenegraph.Tile;
import scenegraph.Circle;
import scenegraph.Line;
import scenegraph.Types;


@:allow(scenegraph.Scene)
class Node {
    private var _scene:Scene;
    private var _xGetter:()->FastFloat;
    private var _yGetter:()->FastFloat;
    private var _xSetter:(FastFloat)->FastFloat;
    private var _ySetter:(FastFloat)->FastFloat;

    public var id(get, null):Int;
    public var name(get, set):String;
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
    public var rWidth(get, null):FastFloat;
    public var rHeight(get, null):FastFloat;
    public var rPos(get, null):FastVector2;
    public var parent(get, null):Node;

    public function new(?x:FastFloat = 0, ?y:FastFloat = 0, ?parent:Node = null, ?scene:Scene = null,
                        ?_root:Bool = false, ?name:String = null) {
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
        this.id = _scene.newNode(this);
        this.x = x;
        this.y = y;
        this.shown = true;
        if (parent != null) {
            reparentTo(parent);
        }
        else {
            _scene.propagateDirty(this.id);
        }
        _scene.name[this.id] = name;
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
        this.parent = parent;
    }

    public function attachNode():Node {
        return new Node(this);
    }

    public function attachSprite(?x:FastFloat = 0, ?y:FastFloat = 0, image:Image, ?rect:SourceRect = null, ?color:Color = null):Sprite {
        return new Sprite(x, y, image, rect, this, color);
    }

    public function attachText(?text:String = "", font:Font, fontSize:FastFloat,
                               ?color:Color = Color.White):Text {
        return new Text(text, font, fontSize, color, this);
    }

    public function attachNested(?x:FastFloat = 0, ?y:FastFloat = 0, rect:Rect):NestedScene {
        return new NestedScene(x, y, rect, this);
    }

    public function attachTile(?x:FastFloat = 0, ?y:FastFloat = 0, width:FastFloat, height:FastFloat, corner:CornerRadius, color:Color, ?border:FastFloat = 0, ?borderColor:Color = null):Tile {
        return new Tile(x, y, width, height, corner, color, border, borderColor, this);
    }

    public function attachFmtText(?x:FastFloat = 0, ?y:FastFloat = 0, xmlText:String, defaultFont:Font, ?defaultSz:Null<FastFloat> = null, ?defaultColor:Color = Color.White, ?align:HAlign = LEFT):FmtText {
        return new FmtText(x, y, xmlText, defaultFont, defaultSz, defaultColor, align, this);
    }

    public function attachCircle(?x:FastFloat = 0, ?y:FastFloat = 0, radius:FastFloat, color:Color, ?border:FastFloat = 0, ?borderColor:Color = null):Circle {
        return new Circle(x, y, radius, color, border, borderColor, this);
    }

    public function attachLine(x1:FastFloat, y1:FastFloat, x2:FastFloat, y2:FastFloat, color:Color, ?strength:FastFloat = 0):Line {
        return new Line(x1, y1, x2, y2, color, strength, this);
    }

    public inline function inside(ox:FastFloat, oy:FastFloat):Bool {
        if (_scene.flags[id] & IS_CIRCLE > 0) {
            var center = new FastVector2(x, y);
            var point = new FastVector2(ox, oy);
            var delta = center.sub(point).length;
            return delta <= _scene.circleRadius[_scene.circleId[id]];
        }
        if (_scene.flags[id] & DIRTY > 0) {
            _scene.traverse();
        }
        var tl = new FastVector2(0, 0);
        var tr = new FastVector2(width * _scene.pxPerUnit, 0);
        var bl = new FastVector2(0, height * _scene.pxPerUnit);
        var br = new FastVector2(width * _scene.pxPerUnit, height * _scene.pxPerUnit);
        tl = _scene.transform[id].multvec(tl);
        tr = _scene.transform[id].multvec(tr);
        bl = _scene.transform[id].multvec(bl);
        br = _scene.transform[id].multvec(br);
        var l = Math.min(tl.x / _scene.pxPerUnit, Math.min(tr.x / _scene.pxPerUnit, Math.min(bl.x / _scene.pxPerUnit, br.x / _scene.pxPerUnit)));
        var r = Math.max(tl.x / _scene.pxPerUnit, Math.max(tr.x / _scene.pxPerUnit, Math.max(bl.x / _scene.pxPerUnit, br.x / _scene.pxPerUnit)));
        var t = Math.min(tl.y / _scene.pxPerUnit, Math.min(tr.y / _scene.pxPerUnit, Math.min(bl.y / _scene.pxPerUnit, br.y / _scene.pxPerUnit)));
        var b = Math.max(tl.y / _scene.pxPerUnit, Math.max(tr.y / _scene.pxPerUnit, Math.max(bl.y / _scene.pxPerUnit, br.y / _scene.pxPerUnit)));
        return l <= ox && r >= ox && t <= oy && b >= oy;
    }

    public inline function overlap(ox:FastFloat, oy:FastFloat, w:FastFloat, h:FastFloat) {
        var r = inside(ox, oy) || inside(ox + w, oy) || inside(ox, oy + h) || inside(ox + w, oy + h);
        if (r) {
            return r;
        }
        var tl = _scene.transform[id].multvec(new FastVector2(0, 0));
        return tl.x / _scene.pxPerUnit >= ox && tl.x / _scene.pxPerUnit <= ox + w
            && tl.y / _scene.pxPerUnit >= oy && tl.y / _scene.pxPerUnit <= oy + h;
    }

    // Getter/Setter
    public inline function get_parent():Node {
        return this.parent;
    }

    public inline function getRelativePos(node:Node):FastVector2 {
        _scene.traverse(false);
        var idVec = new FastVector2(1, 1);
        return _scene.transform[id].multvec(idVec).mult(1 / _scene.pxPerUnit).sub(_scene.transform[node.id].multvec(idVec).mult(1 / _scene.pxPerUnit));
    }

    public inline function setRelativePos(node:Node, x:FastFloat, y:FastFloat) {
        _scene.traverse(false);
        var idVec = new FastVector2(1, 1);
        var pos = new FastVector2(x, y);
        var delta = _scene.transform[node.id].multvec(idVec).mult(1 / _scene.pxPerUnit).add(pos);
        delta = _scene.transform[id].multvec(idVec).mult(1 / _scene.pxPerUnit).sub(delta);
        this.x -= delta.x;
        this.y -= delta.y;
    }

    public inline function getRelativeAngle(node:Node):FastFloat {
        _scene.traverse(false);
        return Math.atan2(-_scene.transform[id]._01, _scene.transform[id]._00) - Math.atan2(-_scene.transform[node.id]._01, _scene.transform[node.id]._00);
    }

    public inline function setRelativeAngle(node:Node, rad:FastFloat) {
        _scene.traverse(false);
        var delta = Math.atan2(-_scene.transform[node.id]._01, _scene.transform[node.id]._00);
        angle -= delta + rad + angle;
    }

    public inline function getRelativeScaleX(node:Node):FastFloat {
        _scene.traverse(false);
        var thisScale = Math.sqrt(Math.pow(_scene.transform[id]._00, 2) + Math.pow(_scene.transform[id]._10, 2));
        var otherScale = Math.sqrt(Math.pow(_scene.transform[node.id]._00, 2) + Math.pow(_scene.transform[node.id]._10, 2));
        return thisScale / otherScale;
    }

    public inline function getRelativeScaleY(node:Node):FastFloat {
        _scene.traverse(false);
        var thisScale = Math.sqrt(Math.pow(_scene.transform[id]._01, 2) + Math.pow(_scene.transform[id]._11, 2));
        var otherScale = Math.sqrt(Math.pow(_scene.transform[node.id]._01, 2) + Math.pow(_scene.transform[node.id]._11, 2));
        return thisScale / otherScale;
    }

    public inline function setRelativeScale(node:Node, sx:FastFloat, ?sy:FastFloat = -1) {
        _scene.traverse(false);
        var thisScale = Math.sqrt(Math.pow(_scene.transform[id]._00, 2) + Math.pow(_scene.transform[id]._10, 2));
        thisScale /= scaleX;
        var otherScale = Math.sqrt(Math.pow(_scene.transform[node.id]._00, 2) + Math.pow(_scene.transform[node.id]._10, 2));
        scaleX = thisScale * (otherScale * sx);
        thisScale = Math.sqrt(Math.pow(_scene.transform[id]._01, 2) + Math.pow(_scene.transform[id]._11, 2));
        thisScale /= scaleY;
        otherScale = Math.sqrt(Math.pow(_scene.transform[node.id]._01, 2) + Math.pow(_scene.transform[node.id]._11, 2));
        scaleY = thisScale * (otherScale * (sy > 0 ? sy : sx));
    }

    public inline function setRelativeScaleX(node:Node, sx:FastFloat) {
        _scene.traverse(false);
        var thisScale = Math.sqrt(Math.pow(_scene.transform[id]._00, 2) + Math.pow(_scene.transform[id]._10, 2));
        thisScale /= scaleX;
        var otherScale = Math.sqrt(Math.pow(_scene.transform[node.id]._00, 2) + Math.pow(_scene.transform[node.id]._10, 2));
        scaleX = thisScale * (otherScale * sx);
    }

    public inline function setRelativeScaleY(node:Node, sy:FastFloat) {
        _scene.traverse(false);
        var thisScale = Math.sqrt(Math.pow(_scene.transform[id]._01, 2) + Math.pow(_scene.transform[id]._11, 2));
        thisScale /= scaleY;
        var otherScale = Math.sqrt(Math.pow(_scene.transform[node.id]._01, 2) + Math.pow(_scene.transform[node.id]._11, 2));
        scaleY = thisScale * (otherScale * sy);
    }

    public inline function getRelativeDepth(node:Node):Int {
        _scene.traverse(false);
        return _scene.absDepth[id] - _scene.absDepth[node.id];
    }

    public inline function setRelativeDepth(node:Node, d:Int) {
        _scene.traverse(false);
        depth += _scene.absDepth[node.id] + d - _scene.absDepth[id];
    }

    private inline function get_id():Int {
        return id;
    }

    private inline function get_name():String {
        return _scene.name[id];
    }

    private inline function set_name(v:String):String {
        _scene.name[id] = v;
        return _scene.name[id];
    }

    private inline function get_x():FastFloat {
        if (_xGetter != null) {
            return _xGetter();
        }
        return _scene.x[id];
    }

    private inline function set_x(v:FastFloat):FastFloat {
        if (_xSetter != null) {
            return _xSetter(v);
        }
        _scene.x[id] = v;
        _scene.propagateDirty(id);
        return _scene.x[id];
    }

    private inline function get_y():FastFloat {
        if (_yGetter != null) {
            return _yGetter();
        }
        return _scene.y[id];
    }

    private inline function set_y(v:FastFloat):FastFloat {
        if (_ySetter != null) {
            return _ySetter(v);
        }
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
        _scene.propagateDirty(id);
        return _scene.width[id];
    }

    private inline function get_height():FastFloat {
        return _scene.height[id];
    }

    private function set_height(v:FastFloat):FastFloat {
        _scene.height[id] = v;
        _scene.propagateDirty(id);
        return _scene.height[id];
    }

    private inline function get_rWidth():FastFloat {
        return _scene.width[id] * Math.sqrt(Math.pow(_scene.transform[id]._00, 2) + Math.pow(_scene.transform[id]._10, 2));
    }

    private inline function get_rHeight():FastFloat {
        return _scene.height[id] * Math.sqrt(Math.pow(_scene.transform[id]._01, 2) + Math.pow(_scene.transform[id]._11, 2));
    }

    private inline function get_rPos():FastVector2 {
        return _scene.transform[id].multvec(new FastVector2()).div(_scene.pxPerUnit);
    }

    public function toString():String {
        var nType = "Node";
        if (_scene.flags[id] & IS_IMAGE > 0) {
            nType = "Sprite";
        }
        else if (_scene.flags[id] & IS_TEXT > 0) {
            nType = "Text";
        }
        else if (_scene.flags[id] & IS_NESTED > 0) {
            nType = "NestedScene";
        }
        else if (_scene.flags[id] & IS_TILE > 0) {
            nType = "Tile";
        }

        if (_scene.name[id] != null) {
            return _scene.name[id] + " [" + nType + " " + id + "]";
        }
        return id + " (" + nType + ")";
    }
}
