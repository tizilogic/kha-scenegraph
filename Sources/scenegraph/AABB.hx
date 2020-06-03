package scenegraph;

import kha.math.FastVector2;
import kha.math.Vector2;


class AABB {
    public var pos(get_pos, set_pos):FastVector2;
    public var hw:FastFloat;
    public var hh:FastFloat;

    public function new(?vpos:FastVector2, ?x:FastFloat, ?y:FastFloat,
                        hw:FastFloat, hh:FastFloat) {
        set_pos(vpos, x, y);
        this.hw = hw;
        this.hh = hh;
    }

    public function intersect(other: AABB): Bool {
        var tl = x - hw;
        var tr = x + hw;
        var tt = y - hh;
        var tb = y + hh;
        var ol = other.x - hw;
        var or = other.x + hw;
        var ot = other.y - hh;
        var ob = other.y + hh;
        return ((((ol > tl && ol < tr) || (or > tl && or < tr))
                 && ((ot > tt && ot < tb) || (ob > tt && ob < tb))) // Partial intersect
                || (ol < tl && or > tr && ot < tt && ob > tb)); // This inside other
    }

    public function vec_inside(other: Vector2): Bool {
        var tl = x - hw;
        var tr = x + hw;
        var tt = y - hh;
        var tb = y + hh;
        return (other.x > tl && other.x < tr && other.y > tt && other.y < tb);
    }

    public function get_pos():FastVector2 {
        return pos;
    }

    public function set_pos(?vpos:FastVector2, ?x:FastFloat, ?y:FastFloat) {
        if (vpos != null) {
            pos = vpos;
        }
        else if (x != null && y != null) {
            pos.x = x;
            pos.y = y;
        }
        else {
            throw "Either pass a vector or both components of it";
        }
    }
}