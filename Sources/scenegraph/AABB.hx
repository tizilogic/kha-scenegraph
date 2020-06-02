package scenegraph;

import kha.FastFloat;
import kha.math.Vector2;


class AABB {
    public var x:FastFloat;
    public var y:FastFloat;
    public var hw:FastFloat;
    public var hh:FastFloat;

    public function new(x:FastFloat, y:FastFloat, hw:FastFloat, hh:FastFloat) {
        this.x = x;
        this.y = y;
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
}