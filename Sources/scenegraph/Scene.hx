package scenegraph;

import kha.Color;
import kha.FastFloat;
import kha.Font;
import kha.Image;
import kha.System;
import kha.math.FastMatrix3;
import scenegraph.Types;
import scenegraph.Node;


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

    // System
    private var _renderOrder = new Array<Int>();
    private var _visible:Array<Int>;
    private var _toProcess = new Array<Int>();
    public var pxPerUnit(default, null):FastFloat;
    public var bgColor = Color.Black;
    private var _buffer:Image;

    // Node
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
    private var flags = new Array<Int>();
    private var transform = new Array<FastMatrix3>();
    private var parent = new Array<Int>();
    private var imageId = new Array<Int>();
    private var textId = new Array<Int>();

    // Sprite
    private var image = new Array<Image>();
    private var sx = new Array<FastFloat>();
    private var sy = new Array<FastFloat>();
    private var sw = new Array<FastFloat>();
    private var sh = new Array<FastFloat>();

    // Text
    private var text = new Array<String>();
    private var font = new Array<Font>();
    private var fontSize = new Array<Int>();
    private var color = new Array<Color>();

    private var _free = new Array<Int>();
    private var _freeImage = new Array<Int>();
    private var _freeText = new Array<Int>();


    public function new(?buffer:Image = null, ?reserve:Int = 0) {
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
        flags.resize(reserve + 1);
        transform.resize(reserve + 1);
        parent.resize(reserve + 1);
        imageId.resize(reserve + 1);
        textId.resize(reserve + 1);

        // Root
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
        flags[0] = DIRTY;
        transform[0] = FastMatrix3.identity();
        parent[0] = 0;
        imageId[0] = -1;
        textId[0] = -1;

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
        if (buffer == null) {
            _buffer = Image.createRenderTarget(System.windowWidth(), System.windowHeight());
        }
        else {
            _buffer = buffer;
        }
        this.pxPerUnit = Math.min(_buffer.width, _buffer.height);
    }

    private function insertImage(nodeId:Int, image:Image, ?rect:SourceRect = null) {
        var id:Int;
        var sRect:SourceRect = rect == null ? {sx:0, sy:0, sw:image.width, sh:image.height} : rect;
        if (_freeImage.length > 0) {
            id = _freeImage.pop();
            this.image[id] = image;
            sx[id] = sRect.sx;
            sy[id] = sRect.sy;
            sw[id] = sRect.sw;
            sh[id] = sRect.sh;
        }
        else {
            id = this.image.length;
            this.image.push(image);
            sx.push(sRect.sx);
            sy.push(sRect.sy);
            sw.push(sRect.sw);
            sh.push(sRect.sh);
        }
        imageId[nodeId] = id;
        _renderOrder.push(nodeId);
        width[nodeId] = sw[id] / pxPerUnit;
        height[nodeId] = sh[id] / pxPerUnit;
    }

    private function insertText(nodeId:Int, text:String, font:Font, fontSize:FastFloat, color:Color) {
        var id:Int;
        var fs = Std.int(fontSize * pxPerUnit + 0.5);
        if (_freeText.length > 0) {
            id = _freeText.pop();
            this.text[id] = text;
            this.font[id] = font;
            this.fontSize[id] = fs;
            this.color[id] = color;
        }
        else {
            id = this.text.length;
            this.text.push(text);
            this.font.push(font);
            this.fontSize.push(fs);
            this.color.push(color);
        }
        textId[nodeId] = id;
        _renderOrder.push(nodeId);
        width[nodeId] =  font.width(fs, text) / pxPerUnit;
        height[nodeId] = font.height(fs) / pxPerUnit;
    }

    private function get_root():Node {
        return nodes[this][0];
    }

    private inline function updateTransform(pid:Int, parentTransform:FastMatrix3) {
        var dx = x[pid] * pxPerUnit;
        var dy = y[pid] * pxPerUnit;
        transform[pid] = parentTransform.multmat(FastMatrix3.translation(dx, dy))
            .multmat(FastMatrix3.scale(scaleX[pid], scaleY[pid]));
        if (angle[pid] != 0) {
            var hw = flags[pid] & HAS_ROT_CENTER > 0 ? rotX[pid] * pxPerUnit : (width[pid] * pxPerUnit) / 2;
            var hh = flags[pid] & HAS_ROT_CENTER > 0 ? rotY[pid] * pxPerUnit : (height[pid] * pxPerUnit) / 2;
            transform[pid] = transform[pid].multmat(FastMatrix3.translation(hw, hh))
                .multmat(FastMatrix3.rotation(angle[pid]))
                .multmat(FastMatrix3.translation(-hw, -hh));
        }
        absDepth[pid] = absDepth[parent[pid]] + depth[parent[pid]] + depth[pid];
    }

    public function traverse(?skipHidden:Bool = true):Bool {
        if (flags[0] & DIRTY == 0 || flags[0] & HIDDEN > 0) {
            return false;
        }
        var cursor = 0;
        _toProcess.push(0);
        while (_toProcess.length > 0) {
            var pid = _toProcess.pop();
            var pTrans = transform[pid];
            for (i in 1...flags.length) {
                if (flags[i] & FREE > 0 || (flags[i] & HIDDEN > 0 && skipHidden) || parent[i] != pid ) {
                    continue;
                }
                if (flags[i] & DIRTY > 0) {
                    updateTransform(i, pTrans);
                }
                _toProcess.push(i);
            }
            if ((flags[pid] & IS_IMAGE) + (flags[pid] & IS_TEXT) > 0) {
                _renderOrder[cursor] = pid;
                ++cursor;
            }
            flags[pid] = flags[pid] & DIRTY > 0 ? flags[pid] ^ DIRTY : flags[pid];
        }
        _visible = _renderOrder.slice(0, cursor);
        _visible.sort(comp);
        return true;
    }

    private inline function comp(x:Int, y:Int):Int {
        return absDepth[x] == absDepth[y] ? 0 : absDepth[x] > absDepth[y] ? 1 : -1;
    }

    public function render():Image {
        var g = _buffer.g2;

        if (traverse()) {
            g.begin(true, bgColor);
            g.color = bgColor;
            g.fillRect(0, 0, _buffer.width, _buffer.height);
            g.color = Color.White;
            for (i in _visible) {
                g.pushOpacity(alpha[i]);
                g.pushTransformation(transform[i]);
                if (flags[i] & IS_IMAGE > 0) {
                    var id = imageId[i];
                    g.drawSubImage(image[id], 0, 0, sx[id], sy[id], sw[id], sh[id]);
                }
                else if (flags[i] & IS_TEXT > 0) {
                    var id = textId[i];
                    var prevColor = g.color;
                    g.color = color[id];
                    g.font = font[id];
                    g.fontSize = fontSize[id];
                    g.drawString(text[id], 0, 0);
                    g.color = prevColor;
                }
                g.popTransformation();
                g.popOpacity();
            }
            g.end();
        }
        return _buffer;
    }

    public function propagateDirty(nodeId:Int) {
        _toProcess.push(nodeId);
        // Flag all children
        while (_toProcess.length > 0) {
            var pid = _toProcess.pop();
            flags[pid] = flags[pid] | DIRTY;
            for (i in 1...flags.length) {
                if (i == pid || flags[i] & FREE > 0) {
                    continue;
                }
                if (parent[i] == pid) {
                    _toProcess.push(i);
                }
            }
        }

        // Flag direct path to root
        if (parent[nodeId] != nodeId) {
            _toProcess.push(parent[nodeId]);
        }
        while (_toProcess.length > 0) {
            var pid = _toProcess.pop();
            flags[pid] = flags[pid] | DIRTY;
            if (parent[pid] != pid) {
                _toProcess.push(parent[pid]);
            }
        }
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
            absDepth[id] = 0;
            alpha[id] = 1;
            angle[id] = 0;
            transform[id] = null;
            flags[id] = DIRTY;
            parent[id] = id;
            imageId[id] = -1;
            textId[id] = -1;
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
            flags.push(DIRTY);
            transform.push(null);
            parent.push(id);
            imageId.push(-1);
            textId.push(-1);
        }
        return id;
    }

    public function removeNode(nodeId:Int) {
        if (flags[nodeId] & IS_IMAGE > 0) {
            _freeImage.push(imageId[nodeId]);
        }
        else if (flags[nodeId] & IS_TEXT > 0) {
            _freeText.push(textId[nodeId]);
        }
        flags[nodeId] = FREE;
        _free.push(nodeId);
        nodes[this].remove(nodeId);
        while (_renderOrder.remove(nodeId)) {}
    }
}