THREE.BinaryTriangle = function (v1, v2, v3, ln, rn, bn) {
	this.v1 = v1;
	this.v2 = v2;
	this.v3 = v3;
}

THREE.BinaryTriangle.prototype = {
	constructor: THREE.BinaryTriangle,
	v1:null,
	v2:null,
	v3:null,
	lc:null,
	rc:null,
	ln:null,
	rn:null,
	bn:null,
	
	getIndexBuffer : function () {
		return new THREE.Face3( this.v1, this.v2, this.v3 );
	},
	
	getVariance: function (img) {
		
	}
	
	
	/*
	split: function () {
		if (this.bn) {
			if (this.bn.bn != this) {
				this.bn.split();
			}
			this.split2();
			this.lc.rn = this.bn.rc;
			this.rc.ln = this.bn.lc;
			this.bn.lc.rn = this.rc;
			this.bn.rc.ln = this.lc;
		} else {
			this.split2();
			this.lc.rn = null;
			this.rc.ln = null;
		}
	},
	
	split2 : function () {
		this.lc = new THREE.BinaryTriangle();
		this.rc = new THREE.BinaryTriangle();
		this.lc.ln = this.rc;
		this.rc.rn = this.lc;
		this.lc.bn = this.ln;
		
		if (this.ln) {
			if (this.ln.bn == this) {
				this.ln.bn = this.lc;
			} else {
				if ( this.ln.ln == this ) {
					this.ln.ln = this.lc;
				} else {
					this.ln.rn = this.lc;
				}
			}
		}
		
		this.rc.bn = this.rn;
		if ( this.rn ) {
			if ( this.rn.bn == this) {
				this.rn.bn = this.rc;
			} else {
				if ( this.rn.rn == this) {
					this.rn.rn = this.rc;
				} else {
					this.rn.ln = this.rc;
				}
			}
		}
		
		this.lc.lc = null;
		this.lc.rc = null;
		this.rc.lc = null;
		this.rc.rc = null;
	}*/
}

/*THREE.BinaryTrianglePatch = function (x, z, size, maxLOD) {
	this.x = x || 0;
	this.y = y || 0;
	this.z = z || 0;
	this.size = ( size !== undefined ) ? size : 64.0;
	this.maxLOD = 4; // will become 2n + 1
}

THREE.BinaryTrianglePatch.prototype = {
		constructor : THREE.BinaryTrianglePatch,
		geom : new THREE.Geometry(),
		triangles:[],
		createVertexBuffer : function () {
			var sideLength = ( 2 * this.maxLOD ) + 1
			var step = this.size / sideLength;
			for ( var x = 0; x <= this.size; x+=step ) {
				for ( var z = 0; z <= this.size; z+=step ) {
					this.geom.vertices.push( new THREE.Vertex( new THREE.Vector3(x, 0.0, y)))
				}
			}
		},
		
		traverse: function (p0, p1, p2) {
			
		}
		
}*/




