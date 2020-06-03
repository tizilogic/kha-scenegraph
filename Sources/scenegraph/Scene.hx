package scenegraph;


import kha.math.FastMatrix3;
import kha.math.FastVector2;

class Scene {
    private var _aabb:Array<AABB>;
    private var _parent:Array<Int>;
    private var _origin:Array<FastVector2>;
    private var _depth:Array<Int>;
    private var _tmat:Array<FastMatrix3>;
    private var _flags:Array<Bytes>;
    private var _free:Array<Bool>;


    public function new(?reserveSize:Int) {
        _aabb = new Array<AABB>();
        _parent = new Array<Int>();
        _origin = new Array<FastVector2>();
        _depth = new Array<Int>();
        _tmat = new Array<FastMatrix3>();
        _flags = new Array<Bytes>();
        _free = new Array<Bool>();

        if (reserveSize != null) {
            _aabb.resize(reserveSize);
            _parent.resize(reserveSize);
            _origin.resize(reserveSize);
            _depth.resize(reserveSize);
            _tmat.resize(reserveSize);
            _flags.resize(reserveSize);
            _free.resize(reserveSize);
        }
    }

    public function toString() {
        return "Scene (" + _aabb.length + " Nodes)";
    }
}
