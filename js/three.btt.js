THREE.BinaryTriangle = function (parent) {
	this.parent = parent;
}


THREE.BinaryTriangle.prototype = {
	constructor: THREE.BinaryTriangle,
	hasChildren: false,
	// left child
	lc:null,
	// right child
	rc:null,
	// bottom neighbour
	bn:null,
	// left neighbour
	ln:null,
	// right neighbour
	rn:null,
	// debug variable
	//TODO: REMOVETH THIS
	wonkey: false,
	
	split: function () {
		if (this.bn) {
			
			if (this.bn.bn != this) {
				// if we don't share hypotenuse with bottom neighbour, split bottom neighbour
				this.wonkey = true;
				this.bn.split();
			}
			this.bn.split2();
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
		this.lc = new THREE.BinaryTriangle(this);
		this.rc = new THREE.BinaryTriangle(this);
		this.hasChildren=true;

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
	}
}

THREE.BinaryTrianglePatch = function (worldX, worldY, width, height, maxRecursion) {
	
	this.maxRecursion = maxRecursion || 4;
	
	this.worldX = worldX;
	this.worldY = worldY;
	this.width = width;
	this.height = height;
	this.leftRoot = new THREE.BinaryTriangle(null);
	this.rightRoot = new THREE.BinaryTriangle(null);
	this.leftRoot.bn = this.rightRoot;
	this.rightRoot.bn = this.leftRoot;
	this.geom = new THREE.Geometry();
}

THREE.BinaryTrianglePatch.prototype = {
	constructor: THREE.BinaryTrianglePatch,
	
	buildSplits : function (bitstring) {
		var remainder = this.recursiveSplit(this.leftRoot, bitstring);
		this.recursiveSplit(this.rightRoot, remainder);
	},
	
	recursiveSplit : function (node, bitstring) {
		if (bitstring=="") {
			return bitstring;
		}
		
		var n = parseInt(bitstring.substr(0,1));
		var _tree = bitstring.substr(1);
		if ( n ) {
			node.split();
			var remainder = this.recursiveSplit( node.lc, _tree );
			remainder = this.recursiveSplit( node.rc, remainder );
			return remainder;
		} else {
			return _tree;
		}
	},
	
	
	buildVarianceIndex : function (heightMap, lod) {
		lod = lod || 4;
		var leftIndex = this.traverseVarianceIndex(0, 0, 0, this.height, this.width, 0, heightMap, 0, lod);
		var rightIndex = this.traverseVarianceIndex(this.width, this.height, this.width, 0, 0, this.height, heightMap, 0, lod);
		this.buildSplits(leftIndex);
	},
	
	traverseVarianceIndex : function (apexX, apexY, leftX, leftY, rightX, rightY, img, depth, maxdepth)  {
		if ( depth > maxdepth ) {
			return "0";
		}
		
		var heightA = getNormalizedHeight(img, leftX, leftY);
		var heightB = getNormalizedHeight(img, rightX, rightY);
		
		var avgHeight = (heightA + heightB) / 2.0;
		
		var centerX = (leftX+rightX) >> 1;
		var centerY = (leftY+rightY) >> 1;
		
		var realHeight = getNormalizedHeight(img, centerX, centerY);
		
		var delta = Math.abs(realHeight - avgHeight);
		
		var ret = delta > 0 ? "1" : "0";
		
		if (ret == "1") {
			ret += this.traverseVarianceIndex( centerX, centerY, apexX, apexY, leftX, leftY, img, depth+1, maxdepth );
			ret += this.traverseVarianceIndex( centerX, centerY, rightX, rightY, apexX, apexY, img, depth+1, maxdepth );
		}
		return ret;
	},
	
	
	
	buildVarianceTree : function (heightMap) {
		
		
		this.recurseVarianceTree(this.leftRoot, 0, 0, 0, this.height, this.width, 0, heightMap, 0);
		this.recurseVarianceTree(this.rightRoot, this.width, this.height, this.width, 0, 0, this.height, heightMap, 0);
		
	},
	
	recurseVarianceTree : function (node, apexX, apexY, leftX, leftY, rightX, rightY, img, depth) {
		if (depth > this.maxRecursion) {
			return;
		}
		
		var heightA = getNormalizedHeight(img, leftX, leftY);
		var heightB = getNormalizedHeight(img, rightX, rightY);
		
		var avgHeight = (heightA + heightB) / 2.0;
		
		var centerX = (leftX+rightX) >> 1;
		var centerY = (leftY+rightY) >> 1;
		
		var realHeight = getNormalizedHeight(img, centerX, centerY);
		
		var delta = Math.abs(realHeight - avgHeight);
		
		
		
		if (delta >=0.00) {
			node.split();
			
			this.recurseVarianceTree(node.lc, centerX, centerY, apexX, apexY, leftX, leftY, img, depth+1);
			this.recurseVarianceTree(node.rc, centerX, centerY, rightX, rightY, apexX, apexY, img, depth+1);
		}
	},
	
	buildGeometry : function (img) {
		this.recursiveRender(this.leftRoot, 0, 0, 0, this.height, this.width, 0, img);
		this.recursiveRender(this.rightRoot, this.width, this.height, this.width, 0, 0, this.height, img);
		//this.geom.mergeVertices();
		this.geom.computeFaceNormals();
		this.geom.computeVertexNormals();
		this.object = new THREE.Mesh( this.geom, new THREE.MeshBasicMaterial({vertexColors: THREE.VertexColors, wireframe:true }));
		this.object.position = new THREE.Vector3(this.worldX, 0.0, this.worldY);
	},
	
	recursiveRender : function (node, apexX, apexY, leftX, leftY, rightX, rightY, img) {
		if (node.hasChildren) {
			// continue recursive render
			var centerX = (leftX+rightX) >> 1;
			var centerY = (leftY+rightY) >> 1;
			this.recursiveRender(node.lc, centerX, centerY, apexX, apexY, leftX, leftY, img);
			this.recursiveRender(node.rc, centerX, centerY, rightX, rightY, apexX, apexY, img);
		} else {
			// leaf node, render this triangle
			var ind = this.geom.vertices.length-1;
			
			var apexHeight = getNormalizedHeight(img, this.width - apexX, this.height - apexY) * 50.0;
			var leftHeight = getNormalizedHeight(img, this.width - leftX, this.height - leftY) * 50.0;
			var rightHeight = getNormalizedHeight(img, this.width - rightX, this.height - rightY) * 50.0;
			
			this.geom.vertices.push(new THREE.Vector3(apexX, apexHeight, apexY));
			this.geom.vertices.push(new THREE.Vector3(leftX, leftHeight, leftY));
			this.geom.vertices.push(new THREE.Vector3(rightX, rightHeight, rightY));
			
			this.geom.faces.push(new THREE.Face3(ind+1, ind+2, ind+3));
			
			var fIndex = this.geom.faces.length - 1;
			
			// color code the vertices by apex, left, right
			
			
			this.geom.faces[fIndex].vertexColors[0] = new THREE.Color(0xFF0000);
			this.geom.faces[fIndex].vertexColors[1] = new THREE.Color(node.wonkey ? 0x0000FF : 0x00FF00);
			this.geom.faces[fIndex].vertexColors[2] = new THREE.Color(node.wonkey ? 0x0000FF : 0x00FF00);
			
			
			
		}
	}
}