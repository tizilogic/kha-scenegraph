package scenegraph;

import kha.graphics2.Graphics;
import kha.FastFloat;
import kha.Image;
import scenegraph.Scene;
import scenegraph.Node;


typedef Rect = {sx:FastFloat, sy:FastFloat, sw:FastFloat, sh:FastFloat};


class Sprite extends Node {
    public var image:Image;
    public var rect:Rect;

    public function new(?x:FastFloat = 0, ?y:FastFloat = 0, ?image:Image = null, ?source:Rect = null,
                        ?parent:Node = null, ?scene:Scene = null) {
        super(x, y, parent, scene);
        _scene.flags[id] = _scene.flags[id] | IS_IMAGE;
        this.image = image;
        this.rect = source;
        _scene._renderOrder.push(this);
    }

    private inline function draw(g:Graphics) {
        if (rect == null) {
            g.drawImage(image, 0, 0);
        }
        else {
            g.drawSubImage(image, 0, 0, rect.sx, rect.sy, rect.sw, rect.sh);
        }
    }
}
