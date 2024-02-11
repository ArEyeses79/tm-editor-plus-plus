/// ! This file is generated from ../../../codegen/Camera/GameCamera.xtoml !
/// ! Do not edit this file manually !

// not sure how big this struct actually is
class DGameCamera : RawBufferElem {
	DGameCamera(RawBufferElem@ el) {
		if (el.ElSize != 0x2E8) throw("invalid size for DGameCamera");
		super(el.Ptr, el.ElSize);
	}
	DGameCamera(uint64 ptr) {
		super(ptr, 0x2E8);
	}

	// first 0x10 bytes: uint 0x3, 0x12, 0x13, 0x14
	// can be 1 (norm) or 2 (alt)
	uint8 get_Cam1OrAlt() { return (this.GetUint8(0x24)); }
	void set_Cam1OrAlt(uint8 value) { this.SetUint8(0x24, value); }
	// can be 1 (norm) or 2 (alt)
	uint8 get_Cam2OrAlt() { return (this.GetUint8(0x25)); }
	void set_Cam2OrAlt(uint8 value) { this.SetUint8(0x25, value); }
	// can be 1 (norm) or 2 (alt)
	uint8 get_Cam3OrAlt() { return (this.GetUint8(0x26)); }
	void set_Cam3OrAlt(uint8 value) { this.SetUint8(0x26, value); }
	uint get_t1() { return (this.GetUint32(0x28)); }
	uint get_t2() { return (this.GetUint32(0x2c)); }
	float get_FrameDelta() { return (this.GetFloat(0x30)); }
	float get_UnkVisEntId1() { return (this.GetFloat(0x3C)); }
	float get_Float1() { return (this.GetFloat(0x40)); }
	// player's vis ent id, either this or 0x50 is updated in FUN_140db6480
	uint get_VisEntId1() { return (this.GetUint32(0x44)); }
	uint get_PlayerClassId() { return (this.GetUint32(0x48)); }
	// 0FF00000 or EntIdOfMTGhost
	uint get_MTVisEntId() { return (this.GetUint32(0x50)); }
	uint get_Unk54() { return (this.GetUint32(0x54)); }
	// 1 when viewing gps
	uint get_Unk58() { return (this.GetUint32(0x58)); }
	uint get_ViewingEntityId() { return (this.GetUint32(0x5C)); }
	// CGamePlayer, or CGameCtnMediaClip
	uint get_ViewingClassId() { return (this.GetUint32(0x60)); }
	// 0 in freecam
	uint get_CurrentRaceCamClassId() { return (this.GetUint32(0x68)); }
	// is 0 when mouse outside game in cam1,2,3
	uint get_Unk6C() { return (this.GetUint32(0x6C)); }
	CPlugCamControlModel@ get_CurrentCam() { return cast<CPlugCamControlModel>(this.GetNod(0x70)); }
	uint get_Unk78() { return (this.GetUint32(0x78)); }
	uint get_Unk7C() { return (this.GetUint32(0x7C)); }
	CGameControlCamera@ get_CurrentCamCtrl() { return cast<CGameControlCamera>(this.GetNod(0x80)); }
	CGameControlCameraVehicleInternal@ get_CurrentBwCamCtrl() { return cast<CGameControlCameraVehicleInternal>(this.GetNod(0x88)); }
	CGameResources@ get_FromCameraTween() { return cast<CGameResources>(this.GetNod(0xA8)); }
	// relative to t2
	uint get_StartCameraTweenTime() { return (this.GetUint32(0xB0)); }
	// 0xB4 seems unused
	// 
	CGameResources@ get_GameResources() { return cast<CGameResources>(this.GetNod(0xB8)); }
	// WARNING: Will probs crash the game due to cast (epp-codegen needs updating to handle this case), so just get it via App.GameScene
	ISceneVis@ get_GameScene() { return cast<ISceneVis>(this.GetNod(0xC0)); }
	// 0 normally, 4 when bw, 1 forces no direction change, 0x1 and 0x10 byte not set
	uint get_OverrideCam() { return (this.GetUint32(0xC8)); }
	uint get_VisEntId2() { return (this.GetUint32(0xDC)); }
	uint get_PlayerClassId3() { return (this.GetUint32(0xE0)); }
	uint get_VehicleVisClassId() { return (this.GetUint32(0xE8)); }
	CSceneVehicleVis@ get_VehicleVis() { return cast<CSceneVehicleVis>(this.GetNod(0xF0)); }
	iso4 get_VehicleMatrix() { return (this.GetIso4(0xF8)); }
	// 0x130: vec3, unknonw purpose, not overwritten in editor, but yes in pg
	// 
	bool get_IsMouseOverWindow() { return (this.GetBool(0x178)); }
	vec3 get_CameraPos() { return (this.GetVec3(0x17C)); }
	vec3 get_CursorPickDirection() { return (this.GetVec3(0x188)); }
	NGameMgrMap_SMgr@ get_GameMgrMap() { return cast<NGameMgrMap_SMgr>(this.GetNod(0x198)); }
	// Free = 0x2, Cam1 = 0x12
	uint get_ChosenCamera() { return (this.GetUint32(0x1A8)); }
	void set_ChosenCamera(uint value) { this.SetUint32(0x1A8, value); }
	// 0x230: ptr to unk
	// 
	iso4 get_CameraMatrix() { return (this.GetIso4(0x260)); }
	float get_Fov() { return (this.GetFloat(0x294)); }
	void set_Fov(float value) { this.SetFloat(0x294, value); }
	uint get_UnkVisEntId2B8() { return (this.GetUint32(0x2b8)); }
	void set_UnkVisEntId2B8(uint value) { this.SetUint32(0x2b8, value); }
	uint get_VisEntId2BC() { return (this.GetUint32(0x2bC)); }
	void set_VisEntId2BC(uint value) { this.SetUint32(0x2bC, value); }
	uint get_UnkVisEntId2C0() { return (this.GetUint32(0x2C0)); }
	void set_UnkVisEntId2C0(uint value) { this.SetUint32(0x2C0, value); }
	CGameControlCamera@ get_CurrentCamControl() { return cast<CGameControlCamera>(this.GetNod(0x2D0)); }
}


