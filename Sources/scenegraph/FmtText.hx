package scenegraph;

import haxe.xml.Access;
import kha.Assets;
import kha.Color;
import kha.FastFloat;
import kha.Font;

import scenegraph.Node;
import scenegraph.Scene;
import scenegraph.Text;
import scenegraph.Types;


class FmtText extends Node {
    private var _nodes:Map<Int, Array<Text>>;
    private var _defaultFont:Font;
    private var _defaultSz:Null<FastFloat>;
    private var _defaultColor:Color;

    /**
     * A special text node, allowing to display formatted multiline text.
     * Use `\n` to start a new line inside the text of a `<txt>` element.
     * Beware that any text inside of a `<txt>` tag gets trimmed on the left before processing,
     * while trailing whitespaces/newlines will be added to the rendered text!
     * @param x
     * @param y
     * @param xmlText XML formatted text in the form of `<txt font="FontName" sz="0.05" color="#AARRGGBB" xoffset="0.01" yoffset="-0.005">Displayed Text</txt><txt ...>...</txt>`
     * @param defaultFont Font that will be used if no font attribute is present in an element.
     * @param defaultSz Font size that will be used if no size attribute is present in an element.
     * @param defaultColor Color to be used if no color attribute is present in an element.
     * @param align Alignment of multiline text.
     * @param parent
     * @param scene
     */
    public function new(?x:FastFloat = 0, ?y:FastFloat = 0, xmlText:String, defaultFont:Font, ?defaultSz:Null<FastFloat> = null, ?defaultColor:Color = Color.White, ?align:HAlign = LEFT, ?parent:Node = null, ?scene:Scene = null) {
        super(x, y, parent, scene);
        _defaultFont = defaultFont;
        _defaultSz = defaultSz;
        _defaultColor = defaultColor;
        _nodes = new Map<Int, Array<Text>>();
        parseXml(xmlText, align);
    }

    public inline function parseXml(xmlText:String, ?align:HAlign = LEFT) {
        for (i in _nodes.keys()) {
            while (_nodes[i].length > 0) {
                _nodes[i].pop().destroy();
            }
        }
        _nodes.clear();
        var row = 0;
        var px:FastFloat = 0.0;
        var py:FastFloat = 0.0;
        var xml = Xml.parse(xmlText);
        var left:Null<FastFloat> = null;
        var top:Null<FastFloat> = null;
        var right:Null<FastFloat> = null;
        var bottom:Null<FastFloat> = null;
        for (el in xml.elements()) {
            var txt = StringTools.ltrim(el.firstChild().nodeValue);
            var acc = new Access(el);
            var font = acc.has.font ? Assets.fonts.get(acc.att.font) : _defaultFont;
            var sz = acc.has.sz ? Std.parseFloat(acc.att.sz) : _defaultSz;
            var col = acc.has.color ? Color.fromString(acc.att.color) : _defaultColor;
            var xo:FastFloat = acc.has.xoffset ? Std.parseFloat(acc.att.xoffset) : 0;
            var yo:FastFloat = acc.has.yoffset ? Std.parseFloat(acc.att.yoffset) : 0;
            if (sz == null) {
                throw "Unable to determine font size";
            }
            var last:Text = null;
            for (subtxt in txt.split('\n')) {
                if (last != null) {
                    px = 0.0;
                    py = bottom;
                    xo = 0.0;
                    row++;
                }
                var nd = this.attachText(subtxt, font, sz, col);
                nd.x = px + xo;
                px += nd.width + xo;
                nd.y = py + yo;
                left = left == null ? nd.x : Math.min(left, nd.x);
                top = top == null ? nd.y : Math.min(top, nd.y);
                right = right == null ? nd.x + nd.width : Math.max(right, nd.x + nd.width);
                bottom = bottom == null ? nd.y + nd.height : Math.max(bottom, nd.y + nd.height);
                if (!_nodes.exists(row)) {
                    _nodes[row] = [];
                }
                _nodes[row].push(nd);
                last = nd;
            }
        }
        x += left;
        y += top;
        width = right - left;
        height = bottom - top;
        for (i in 0...row + 1) {
            var xo:FastFloat = 0;
            if (align != LEFT) {
                var leftNd = _nodes[i][0];
                var rightNd = _nodes[i][_nodes[i].length - 1];
                var rowWidth:FastFloat = rightNd.x + rightNd.width - leftNd.x;
                xo = width - rowWidth;
                if (align == CENTER) {
                    xo /= 2;
                }
            }
            for (nd in _nodes[i]) {
                nd.x -= left - xo;
                nd.y -= top;
            }
        }
    }
}
