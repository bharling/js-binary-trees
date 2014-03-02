BT_LEFT_CHILD = 0;
BT_RIGHT_CHILD = 1;
BT_BOTTOM_NEIGHBOUR = 2;
BT_LEFT_NEIGHBOUR = 3;
BT_RIGHT_NEIGHBOUR = 4;
BT_NODE_COLOR = 5;

/*function createBTT () {
	return [null, null, null, null, null, '#'+Math.floor(Math.random()*16777215).toString(16)];
}


function split ( tri ) {
	if (tri[BT_BOTTOM_NEIGHBOUR]) {
			if (tri[BT_BOTTOM_NEIGHBOUR][BT_BOTTOM_NEIGHBOUR] != this) {
				split(tri[BT_BOTTOM_NEIGHBOUR]);
			}
			split2(tri[BT_BOTTOM_NEIGHBOUR]);
			split2(tri);
			
			tri[BT_LEFT_CHILD][BT_RIGHT_NEIGHBOUR] = tri[BT_BOTTOM_NEIGHBOUR][BT_RIGHT_CHILD];
			tri[BT_RIGHT_CHILD][BT_LEFT_NEIGHBOUR] = tri[BT_BOTTOM_NEIGHBOUR][BT_LEFT_CHILD];
			tri[BT_BOTTOM_NEIGHBOUR][BT_LEFT_CHILD][BT_RIGHT_NEIGHBOUR] = tri[BT_RIGHT_CHILD];
			tri[BT_BOTTOM_NEIGHBOUR][BT_RIGHT_CHILD][BT_LEFT_NEIGHBOUR] = tri[BT_LEFT_CHILD];

		} else {
			split2(tri);
			tri[BT_LEFT_CHILD][BT_RIGHT_NEIGHBOUR] = 0;
			tri[BT_RIGHT_CHILD][BT_LEFT_NEIGHBOUR] = 0;
		}
}

function split2 ( tri, root ) {
	
} */

THREE.BinaryTriangle = function (parent) {
	this.parent = parent;
	this.color = '#'+Math.floor(Math.random()*16777215).toString(16);
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
	
	color: 0xFF0000,
	
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
		
		if (this.hasChildren) {
			return;
		}
		
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
	this.geom = new THREE.Geometry({});
	this.lods = [];
	this.worldCenter = new THREE.Vector3(worldX + (width >> 1), 0.0, worldY + (height>>1));
	
}

THREE.BinaryTrianglePatch.prototype = {
	constructor: THREE.BinaryTrianglePatch,
	ready: false,
	
	resetRoots : function () {
		this.leftRoot = new THREE.BinaryTriangle(null);
		this.rightRoot = new THREE.BinaryTriangle(null);
		this.leftRoot.bn = this.rightRoot;
		this.rightRoot.bn = this.leftRoot;
	},
	
	createLodGeometry : function (variance_hi, variance_low, material) {
		this.object = new THREE.LOD();
		
		// hi
		this.resetRoots();
		this.buildSplits(variance_hi);
		var mesh_hi = this.buildLODMesh(material);
		mesh_hi.updateMatrix();
		this.object.addLevel(mesh_hi, 300);
		
		// low
		this.resetRoots();
		this.buildSplits(variance_low);
		var mesh_low = this.buildLODMesh(material);
		mesh_low.updateMatrix();
		this.object.addLevel(mesh_low, 800);
		
		this.object.position.x = this.worldX;
		this.object.position.z = this.worldY;
		
		this.object.updateMatrix();
		this.object.matrixAutoUpdate = false;
		
		
	},
	
	
	buildSplits : function (bitstring) {
		var remainder = this.recursiveSplit(this.leftRoot, bitstring);
		this.recursiveSplit(this.rightRoot, remainder);
	},
	
	buildSplitsLeft: function (bitstring) {
		this.recursiveSplit(this.leftRoot, bitstring);
	},
	
	buildSplitsRight: function (bitstring) {
		this.recursiveSplit(this.rightRoot, bitstring);
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
		
		return rightIndex + leftIndex;
	},
	
	getVariance : function (apexX, apexY, leftX, leftY, rightX, rightY, img) {
		var heightA = getNormalizedHeight(img, leftX, leftY);
		var heightB = getNormalizedHeight(img, rightX, rightY);
		var avgHeight = (heightA + heightB) / 2.0;
		var centerX = (leftX+rightX) >> 1;
		var centerY = (leftY+rightY) >> 1;
		var realHeight = getNormalizedHeight(img, centerX, centerY);
		return Math.abs(realHeight - avgHeight);
	},
	
	traverseVarianceIndex : function (apexX, apexY, leftX, leftY, rightX, rightY, img, depth, maxdepth)  {
		
		var v = this.getVariance(apexX, apexY, leftX, leftY, rightX, rightY, img);
		var centerX = (leftX+rightX) >> 1;
		var centerY = (leftY+rightY) >> 1;
		if ( depth < maxdepth ) {
			v = Math.max(v, this.getVariance( centerX, centerY, apexX, apexY, leftX, leftY, img));
			v = Math.max(v, this.getVariance( centerX, centerY, rightX, rightY, apexX, apexY, img));
		}
		
		var ret = v > 0.02 ? "1" : "0";
		
		if ( depth >= maxdepth && ret == "0") {
			return "0";
		}
		
		
		ret += this.traverseVarianceIndex( centerX, centerY, apexX, apexY, leftX, leftY, img, depth+1, maxdepth );
		ret += this.traverseVarianceIndex( centerX, centerY, rightX, rightY, apexX, apexY, img, depth+1, maxdepth );

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
	
	buildGeometry : function (img, material) {
		material = material || new THREE.MeshBasicMaterial({vertexColors:THREE.VertexColors});
		img = img || 0;
		this.recursiveRender(this.leftRoot, 0, 0, 0, this.height, this.width, 0, img, this.geom);
		this.recursiveRender(this.rightRoot, this.width, this.height, this.width, 0, 0, this.height, img, this.geom);
		this.geom.mergeVertices();
		this.geom.computeFaceNormals();
		this.geom.computeVertexNormals();
		this.object = new THREE.Mesh( this.geom, material);
		this.object.position = new THREE.Vector3(this.worldX, 0.0, this.worldY);
		this.ready = true;
	},
	
	buildLODMesh : function (material) {
		var geom = new THREE.Geometry();
		this.recursiveRender(this.leftRoot, 0, 0, 0, this.height, this.width, 0, null, geom);
		this.recursiveRender(this.rightRoot, this.width, this.height, this.width, 0, 0, this.height, null, geom);
		geom.mergeVertices();
		geom.computeFaceNormals();
		geom.computeVertexNormals();
		var mesh = new THREE.Mesh( geom, material);
		return mesh;
	},
	
	recursiveRender : function (node, apexX, apexY, leftX, leftY, rightX, rightY, img, geom) {
		if (node.hasChildren) {
			// continue recursive render
			var centerX = (leftX+rightX) >> 1;
			var centerY = (leftY+rightY) >> 1;
			this.recursiveRender(node.lc, centerX, centerY, apexX, apexY, leftX, leftY, img, geom);
			this.recursiveRender(node.rc, centerX, centerY, rightX, rightY, apexX, apexY, img, geom);
		} else {
			// leaf node, render this triangle
			var ind = geom.vertices.length-1;
			
			var heightScale = 100.0;
			
			var apexHeight = img ? getNormalizedHeight(img, this.width - apexX, this.height - apexY) * heightScale : 0.0;
			var leftHeight = img ? getNormalizedHeight(img, this.width - leftX, this.height - leftY) * heightScale : 0.0;
			var rightHeight = img ? getNormalizedHeight(img, this.width - rightX, this.height - rightY) * heightScale : 0.0;
			
			geom.vertices.push(new THREE.Vector3(apexX, apexHeight, apexY));
			geom.vertices.push(new THREE.Vector3(leftX, leftHeight, leftY));
			geom.vertices.push(new THREE.Vector3(rightX, rightHeight, rightY));
			
			geom.faceVertexUvs[0].push([
				new THREE.Vector2( apexX / this.width, apexY / this.height ),
				new THREE.Vector2( leftX / this.width, leftY / this.height ),
				new THREE.Vector2( rightX / this.width, rightY / this.height )
			]);
			
			
			geom.faces.push(new THREE.Face3(ind+1, ind+2, ind+3));
			
			var fIndex = geom.faces.length - 1;
			
			// color code the vertices by apex, left, right
			
			
			//this.geom.faces[fIndex].vertexColors[0] = new THREE.Color(0xFF0000);
			//this.geom.faces[fIndex].vertexColors[1] = new THREE.Color(node.wonkey ? 0x0000FF : 0x00FF00);
			//this.geom.faces[fIndex].vertexColors[2] = new THREE.Color(node.wonkey ? 0x0000FF : 0x00FF00);
			
			geom.faces[fIndex].vertexColors[0] = new THREE.Color(node.color);
			geom.faces[fIndex].vertexColors[1] = new THREE.Color(node.color);
			geom.faces[fIndex].vertexColors[2] = new THREE.Color(node.color);
			
			
			
		}
	}
}