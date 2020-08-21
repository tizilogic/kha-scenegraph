package scenegraph;

import kha.Color;
import kha.Font;
import kha.graphics2.Graphics;
import kha.FastFloat;
import kha.Font;
import scenegraph.Scene;
import scenegraph.Node;


class Text extends Node {
    public var text(get, set):String;
    public var font(get, set):Font;
    public var fontSize(get, set):FastFloat;
    public var color(get, set):Color;

    public function new(?x:FastFloat = 0, ?y:FastFloat = 0, ?text:String = "", font:Font, fontSize:FastFloat,
                        ?color:Color = Color.White, ?parent:Node = null, ?scene:Scene = null) {
        super(x, y, parent, scene);
        _scene.flags[id] = _scene.flags[id] | IS_TEXT;
        _scene.insertText(id, text, font, fontSize, color);
    }

    private inline function get_text():String {
        return _scene.text[_scene.textId[id]];
    }

    private inline function set_text(v:String):String {
        _scene.text[_scene.textId[id]] = v;
        updateSize();
        _scene.propagateDirty(id);
        return _scene.text[_scene.textId[id]];
    }

    private inline function get_font():Font {
        return _scene.font[_scene.textId[id]];
    }

    private inline function set_font(v:Font):Font {
        _scene.font[_scene.textId[id]] = v;
        updateSize();
        _scene.propagateDirty(id);
        return _scene.font[_scene.textId[id]];
    }

    private inline function get_fontSize():FastFloat {
        return _scene.fontSize[_scene.textId[id]] / _scene.pxPerUnit;
    }

    private inline function set_fontSize(v:FastFloat):FastFloat {
        _scene.fontSize[_scene.textId[id]] = Std.int(v * _scene.pxPerUnit + 0.5);
        updateSize();
        _scene.propagateDirty(id);
        return _scene.fontSize[_scene.textId[id]] / _scene.pxPerUnit;
    }

    private inline function get_color():Color {
        return _scene.color[_scene.textId[id]];
    }

    private inline function set_color(v:Color):Color {
        _scene.color[_scene.textId[id]] = v;
        _scene.propagateDirty(id);
        return _scene.color[_scene.textId[id]];
    }

    private inline function updateSize() {
        var fs = Std.int(fontSize * _scene.pxPerUnit + 0.5);
        _scene.width[id] = _scene.font[_scene.textId[id]].width(fs, text) / _scene.pxPerUnit;
        _scene.height[id] = _scene.font[_scene.textId[id]].height(fs) / _scene.pxPerUnit;
    }
}
