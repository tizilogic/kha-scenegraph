package scenegraph;

import kha.Color;
import kha.FastFloat;
import kha.Font;
import kha.Image;
import kha.math.FastMatrix3;
import kha.graphics2.Graphics;
import scenegraph.Types;
import scenegraph.Node;
import scenegraph.Sprite;
import scenegraph.Text;


@:enum
abstract NodeFlag (Int) to Int {
    var DIRTY = 1;
    var HIDDEN = 2;
    var IS_IMAGE = 4;
    var IS_TEXT = 8;
    var SUB_IMAGE = 16;
    var HAS_ROT_CENTER = 32;
    var FREE = 64;
}


@:allow(scenegraph.Node)
class Scene {
    public var root(get, null):Node;
    private static var _default:Scene;

    public static function defaultInstance():Scene {
        if (_default == null) {
            _default = new Scene();
        }
        return _default;
    }

    private static var nodes = new Map<Scene, Map<Int, Node>>();
    private var x = new Array<FastFloat>();
    private var y = new Array<FastFloat>();
    private var width = new Array<FastFloat>();
    private var height = new Array<FastFloat>();
    private var rotX = new Array<FastFloat>();
    private var rotY = new Array<FastFloat>();
    private var scaleX = new Array<FastFloat>();
    private var scaleY = new Array<FastFloat>();
    private var depth = new Array<Int>();
    private var absDepth = new Array<Int>();
    private var alpha = new Array<FastFloat>();
    private var angle = new Array<FastFloat>();
    private var absAngle = new Array<FastFloat>();
    private var flags = new Array<Int>();
    private var transform = new Array<FastMatrix3>();
    private var absTransform = new Array<FastMatrix3>();
    private var parent = new Array<Int>();
    private var imageId = new Array<Int>();
    private var textId = new Array<Int>();

    // Sprite
    private var image = new Array<Image>();
    private var sx = new Array<FastFloat>();
    private var sy = new Array<FastFloat>();
    private var sw = new Array<FastFloat>();
    private var sh = new Array<FastFloat>();
    private var dw = new Array<FastFloat>();
    private var dh = new Array<FastFloat>();

    // Text
    private var text = new Array<String>();
    private var font = new Array<Font>();
    private var fontSize = new Array<Int>();
    private var color = new Array<Color>();

    private var _free = new Array<Int>();
    private var _renderOrder = new Array<Node>();

    public function new(?reserve:Int = 0) {
        x.resize(reserve + 1);
        y.resize(reserve + 1);
        width.resize(reserve + 1);
        height.resize(reserve + 1);
        rotX.resize(reserve + 1);
        rotY.resize(reserve + 1);
        scaleX.resize(reserve + 1);
        scaleY.resize(reserve + 1);
        depth.resize(reserve + 1);
        absDepth.resize(reserve + 1);
        alpha.resize(reserve + 1);
        angle.resize(reserve + 1);
        absAngle.resize(reserve + 1);
        flags.resize(reserve + 1);
        transform.resize(reserve + 1);
        absTransform.resize(reserve + 1);
        parent.resize(reserve + 1);
        x[0] = 0;
        y[0] = 0;
        width[0] = 0;
        height[0] = 0;
        rotX[0] = 0;
        rotY[0] = 0;
        scaleX[0] = 1;
        scaleY[0] = 1;
        depth[0] = 0;
        absDepth[0] = 0;
        alpha[0] = 1;
        angle[0] = 0;
        absAngle[0] = 0;
        flags[0] = DIRTY;
        transform[0] = FastMatrix3.identity();
        absTransform[0] = null;
        parent[0] = 0;
        if (reserve > 0) {
            _free.resize(reserve);
            for (i in 1...reserve + 1) {
                scaleX[i] = 1;
                scaleY[i] = 1;
                alpha[i] = 1;
                flags[i] = FREE;
                _free[i - 1] = i;
            }
        }
        nodes[this] = [0 => new Node(this, true)];
    }

    private function insertImage(nodeId:Int, image:Image, rect:DrawRect) {
        imageId[nodeId] = this.image.length;
        this.image.push(image);
    }

    private function get_root():Node {
        return nodes[this][0];
    }

    public function traverse(startNode:Int):Bool {
        return true;
    }

    public function render(g:Graphics) {

    }

    public function propagateDirty(nodeId:Int) {

    }

    public function newNode():Int {
        var id:Int;
        if (_free.length > 0) {
            id = _free.pop();
            x[id] = 0;
            y[id] = 0;
            width[id] = 0;
            height[id] = 0;
            rotX[id] = 0;
            rotY[id] = 0;
            scaleX[id] = 0;
            scaleY[id] = 0;
            depth[id] = 0;
            alpha[id] = 1;
            angle[id] = 0;
            transform[id] = null;
            flags[id] = DIRTY;
            parent[id] = id;
        }
        else {
            id = x.length;
            x.push(0);
            y.push(0);
            width.push(0);
            height.push(0);
            rotX.push(0);
            rotY.push(0);
            scaleX.push(1);
            scaleY.push(1);
            depth.push(0);
            absDepth.push(0);
            alpha.push(1);
            angle.push(0);
            absAngle.push(0);
            flags.push(DIRTY);
            transform.push(null);
            absTransform.push(null);
            parent.push(id);
        }
        return id;
    }

    public function removeNode(nodeId:Int) {
        flags[nodeId] = FREE;
        _free.push(nodeId);
        _renderOrder.remove(nodes[this][nodeId]);
        nodes[this].remove(nodeId);
    }
}