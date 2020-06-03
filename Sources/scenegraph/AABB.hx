package scenegraph;

import kha.math.FastVector2;
import kha.FastFloat;


class AABB {
    @:isVar public var pos(get, set):FastVector2;
    public var hw:FastFloat;
    public var hh:FastFloat;

    public function new(?vpos:FastVector2, ?x:FastFloat, ?y:FastFloat,
                        hw:FastFloat, hh:FastFloat) {
        if (vpos != null)
            this.pos = vpos;
        else
            this.pos = new FastVector2(x, y);
        this.hw = hw;
        this.hh = hh;
    }

    public function intersect(other: AABB): Bool {
        var tl = pos.x - hw;
        var tr = pos.x + hw;
        var tt = pos.y - hh;
        var tb = pos.y + hh;
        var ol = other.get_pos().x - hw;
        var or = other.get_pos().x + hw;
        var ot = other.get_pos().y - hh;
        var ob = other.get_pos().y + hh;
        return ((((ol > tl && ol < tr) || (or > tl && or < tr))
                 && ((ot > tt && ot < tb) || (ob > tt && ob < tb))) // Partial intersect
                || (ol < tl && or > tr && ot < tt && ob > tb)); // This inside other
    }

    public function vec_inside(other: FastVector2): Bool {
        var tl = pos.x - hw;
        var tr = pos.x + hw;
        var tt = pos.y - hh;
        var tb = pos.y + hh;
        return (other.x > tl && other.x < tr && other.y > tt && other.y < tb);
    }

    public function get_pos() {
        return pos;
    }

    public function set_pos(pos:FastVector2) {
        return this.pos = pos;
    }

    public function toString() {
        return "AABB(" + pos + ", " + hw + ", " + hh + ")";
    }
}