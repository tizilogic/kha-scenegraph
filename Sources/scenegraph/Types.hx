package scenegraph;

import kha.FastFloat;


typedef SourceRect = {sx:FastFloat, sy:FastFloat, sw:FastFloat, sh:FastFloat};
typedef Rect = {w:FastFloat, h:FastFloat};

enum HAlign {
    CENTER;
    LEFT;
    RIGHT;
}


@:enum
abstract NodeFlag (Int) to Int {
    var DIRTY = 1;
    var HIDDEN = 2;
    var HAS_ROT_CENTER = 4;
    var HAS_COLOR = 8;
    var FREE = 16;
    var IS_IMAGE = 32;
    var IS_TEXT = 64;
    var IS_NESTED = 128;
    var IS_TILE = 256;
    var IS_CIRCLE = 512;
}
