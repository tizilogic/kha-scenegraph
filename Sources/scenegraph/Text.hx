package scenegraph;

import kha.Color;
import kha.Font;
import kha.graphics2.Graphics;
import kha.FastFloat;
import kha.Image;
import scene.Scene;
import scene.Node;


class Text extends Node {
    public var text:String;
    public var font:Font;
    public var fontSize:Int;
    public var color:Color;

    public function new(?x:FastFloat = 0, ?y:FastFloat = 0, ?text:String = null, ?parent:Node = null,
                        ?scene:Scene = null) {
        super(x, y, parent, scene);
        _scene.flags[id] = _scene.flags[id] | IS_TEXT;
        this.text = text;
        _scene._renderOrder.push(this);
    }

    private inline function draw(g:Graphics) {
        g.font = font;
        g.fontSize = fontSize;
        var prevColor = g.color;
        g.color = color;
        g.drawString(text, 0, 0);
        g.color = prevColor;
    }
}
