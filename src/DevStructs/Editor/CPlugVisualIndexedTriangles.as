/// ! This file is generated from ../../../codegen/Editor/CPlugVisualIndexedTriangles.xtoml !
/// ! Do not edit this file manually !

// same structure as DPlugVisualIndexedTriangles to 0x180
class DPlugVisual3D : RawBufferElem {
	DPlugVisual3D(RawBufferElem@ el) {
		if (el.ElSize != SZ_CPlugVisual3D) throw("invalid size for DPlugVisual3D");
		super(el.Ptr, el.ElSize);
	}
	DPlugVisual3D(uint64 ptr) {
		super(ptr, SZ_CPlugVisual3D);
	}
	DPlugVisual3D(CPlugVisual3D@ nod) {
		if (nod is null) throw("not a CPlugVisual3D");
		super(Dev_GetPointerForNod(nod), SZ_CPlugVisual3D);
	}
	CPlugVisual3D@ get_Nod() {
		return cast<CPlugVisual3D>(Dev_GetNodFromPointer(ptr));
	}

	// 0x24: Flags;
	// --- A__ -> 0__; IsIndexationStatic false, UseVertexNormal false
	// --- __1 -> __0; UseVertexColor false
	uint32 get_flags() { return (this.GetUint32(0x24)); }
	void set_flags(uint32 value) { this.SetUint32(0x24, value); }
	// 0x130: buffer of Faces
	DPV_Vertexs@ get_Vertexes() { return DPV_Vertexs(this.GetBuffer(0x130, 0x28, false)); }
}

class DPV_Vertexs : RawBuffer {
	DPV_Vertexs(RawBuffer@ buf) {
		super(buf.Ptr, buf.ElSize, buf.StructBehindPtr);
	}
	DPV_Vertex@ GetVertex(uint i) {
		return DPV_Vertex(this[i]);
	}
}

class DPV_Vertex : RawBufferElem {
	DPV_Vertex(RawBufferElem@ el) {
		if (el.ElSize != 0x28) throw("invalid size for DPV_Vertex");
		super(el.Ptr, el.ElSize);
	}
	DPV_Vertex(uint64 ptr) {
		super(ptr, 0x28);
	}

	// updated on gpu each frame!
	vec3 get_Pos() { return (this.GetVec3(0)); }
	void set_Pos(vec3 value) { this.SetVec3(0, value); }
	float get_PosX() { return (this.GetFloat(0)); }
	void set_PosX(float value) { this.SetFloat(0, value); }
	float get_PosY() { return (this.GetFloat(4)); }
	void set_PosY(float value) { this.SetFloat(4, value); }
	float get_PosZ() { return (this.GetFloat(8)); }
	void set_PosZ(float value) { this.SetFloat(8, value); }
	// not sure if this is used with selection box at least
	vec3 get_Normal() { return (this.GetVec3(0xC)); }
	void set_Normal(vec3 value) { this.SetVec3(0xC, value); }
	float get_NormalX() { return (this.GetFloat(0xC)); }
	void set_NormalX(float value) { this.SetFloat(0xC, value); }
	float get_NormalY() { return (this.GetFloat(0x10)); }
	void set_NormalY(float value) { this.SetFloat(0x10, value); }
	float get_NormalZ() { return (this.GetFloat(0x14)); }
	void set_NormalZ(float value) { this.SetFloat(0x14, value); }
	// does not update live
	vec4 get_Color() { return (this.GetVec4(0x18)); }
	void set_Color(vec4 value) { this.SetVec4(0x18, value); }
	float get_R() { return (this.GetFloat(0x18)); }
	void set_R(float value) { this.SetFloat(0x18, value); }
	float get_G() { return (this.GetFloat(0x1C)); }
	void set_G(float value) { this.SetFloat(0x1C, value); }
	float get_B() { return (this.GetFloat(0x20)); }
	void set_B(float value) { this.SetFloat(0x20, value); }
	float get_A() { return (this.GetFloat(0x24)); }
	void set_A(float value) { this.SetFloat(0x24, value); }
}


class DPlugVisualIndexedTriangles : RawBufferElem {
	DPlugVisualIndexedTriangles(RawBufferElem@ el) {
		if (el.ElSize != SZ_CPlugVisualIndexedTriangles) throw("invalid size for DPlugVisualIndexedTriangles");
		super(el.Ptr, el.ElSize);
	}
	DPlugVisualIndexedTriangles(uint64 ptr) {
		super(ptr, SZ_CPlugVisualIndexedTriangles);
	}
	DPlugVisualIndexedTriangles(CPlugVisualIndexedTriangles@ nod) {
		if (nod is null) throw("not a CPlugVisualIndexedTriangles");
		super(Dev_GetPointerForNod(nod), SZ_CPlugVisualIndexedTriangles);
	}
	CPlugVisualIndexedTriangles@ get_Nod() {
		return cast<CPlugVisualIndexedTriangles>(Dev_GetNodFromPointer(ptr));
	}

	// 0x18: ptr to unk structure (with ptr back to this at +0x20; maybe gpu related)
	// 0x40: uint(1)
	// 0x60: uint(0)
	// 0x88: vec3(1,1,~0)
	// 0x9A: vec3(1.5,1,.5) midpoint
	// 0xA8: ptr?? (on vehicle shape)
	// 0xB8: uint(1)
	// 0xC0: CPlugVertexStream
	// 0xE0: 1
	// 0xE8: func ptr? / normal ptr? on vehicle shape (to random data)
	// 0xF4: 0xFFFFFFFF
	// 0xF8: 0xF..F
	// 0x108: uint(0)
	// 0x118: uint(0)
	// 0x128: 0xF..F
	// 0x180: CPlugIndexBuffer
	DPlugIndexBuffer@ get_IndexBuffer() { auto _ptr = this.GetUint64(0x180); if (_ptr == 0) return null; return DPlugIndexBuffer(_ptr); }
}


class DPlugIndexBuffer : RawBufferElem {
	DPlugIndexBuffer(RawBufferElem@ el) {
		if (el.ElSize != 56) throw("invalid size for DPlugIndexBuffer");
		super(el.Ptr, el.ElSize);
	}
	DPlugIndexBuffer(uint64 ptr) {
		super(ptr, 56);
	}
	DPlugIndexBuffer(CPlugIndexBuffer@ nod) {
		if (nod is null) throw("not a CPlugIndexBuffer");
		super(Dev_GetPointerForNod(nod), 56);
	}
	CPlugIndexBuffer@ get_Nod() {
		return cast<CPlugIndexBuffer>(Dev_GetNodFromPointer(ptr));
	}

	uint8 get_IsStatic() { return (this.GetUint8(0x20)); }
	void set_IsStatic(uint8 value) { this.SetUint8(0x20, value); }
	uint get_IndexType() { return this.GetUint32(0x20) >> 2; }
	void set_IndexType(uint8 v) { this.SetUint32(0x20, (v << 2) | (this.GetUint32(0x20) & 3)); }
}


// 0x28: buffer of indexes?
// probably some winding.
// 0,1,2,0,2,3,4,5,6,4,6,7,8,9,a,9,b,a,c,d,e,d,f,e,10,11,12,12,11,13
// 0x30: length / IndexCount
class DPlugVertexStream : RawBufferElem {
	DPlugVertexStream(RawBufferElem@ el) {
		if (el.ElSize != 112) throw("invalid size for DPlugVertexStream");
		super(el.Ptr, el.ElSize);
	}
	DPlugVertexStream(uint64 ptr) {
		super(ptr, 112);
	}
	DPlugVertexStream(CPlugVertexStream@ nod) {
		if (nod is null) throw("not a CPlugVertexStream");
		super(Dev_GetPointerForNod(nod), 112);
	}
	CPlugVertexStream@ get_Nod() {
		return cast<CPlugVertexStream>(Dev_GetNodFromPointer(ptr));
	}

	// 0x18: ptr -> { self: 0x0 }
	// 0x30: 20, 20 / 0x14
	// 0x38: 1, flags; 1=IsStatic, 2=IsDirtyVision, 8=SkipVision
	bool get_IsStatic() { return (this.GetBool(0x38)); }
	void set_IsStatic(bool value) { this.SetBool(0x38, value); }
}


