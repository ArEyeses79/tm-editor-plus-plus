const uint16 IM_GameSkinOffset = 0xA0;
const uint16 IM_AuthorOffset = 0xA0;

class ItemModel {
    CGameItemModel@ item;
    ItemModel(CGameItemModel@ item) {
        @this.item = item;
        item.MwAddRef();
    }

    ~ItemModel() {
        item.MwRelease();
    }

    CPlugGameSkin@ get_Skin() {
        return cast<CPlugGameSkin>(Dev::GetOffsetNod(item, IM_GameSkinOffset));
    }

    void DrawTree() {
        // UI::TreeNodeFlags::OpenOnArrow
        if (UI::TreeNode(item.IdName, UI::TreeNodeFlags::DefaultOpen)) {
            ClickableLabel("Author", item.Author.GetName());
            DrawEMEdition();
            DrawEMTree();
            UI::TreePop();
        }
    }

    void DrawEMEdition() {
        auto eme = item.EntityModelEdition;
        auto emeCommon = cast<CGameCommonItemEntityModelEdition>(eme);
        bool isCrystal = emeCommon !is null && emeCommon.MeshCrystal !is null;
        UI::Text("Is a Crystal? " + isCrystal);
        if (eme is null) {
            UI::Text("No EntityModelEdition");
            return;
        }
        if (emeCommon is null) {
            UI::Text("EntityModelEdition is an unknown type: " + UnkType(eme));
            return;
        }
        UI::Text("Todo: more?");
    }

    void DrawEMTree() {
        ItemModelTreeElement(item.EntityModel, "EntityModel").Draw();
    }
}


class ItemModelTreeElement {
    CMwNod@ nod;
    string name;

    CPlugStaticObjectModel@ so;
    CPlugPrefab@ prefab;
    NPlugItem_SVariantList@ varList;
    CPlugFxSystem@ fxSys;
    CPlugVegetTreeModel@ vegetTree;
    CPlugDynaObjectModel@ dynaObject;
    NPlugDyna_SKinematicConstraint@ kenematicConstraint;
    CPlugSpawnModel@ spawnModel;
    CPlugEditorHelper@ editorHelper;
    NPlugTrigger_SWaypoint@ sWaypoint;
    NPlugTrigger_SSpecial@ sSpecial;
    CGameCommonItemEntityModel@ cieModel;
    CPlugSurface@ surf;
    CPlugSolid2Model@ s2m;

    ItemModelTreeElement(CMwNod@ nod, const string &in name) {
        @this.nod = nod;
        this.name = name;
        if (nod is null) return;
        @this.so = cast<CPlugStaticObjectModel>(nod);
        @this.prefab = cast<CPlugPrefab>(nod);
        @this.varList = cast<NPlugItem_SVariantList>(nod);
        @this.fxSys = cast<CPlugFxSystem>(nod);
        @this.vegetTree = cast<CPlugVegetTreeModel>(nod);
        @this.dynaObject = cast<CPlugDynaObjectModel>(nod);
        @this.kenematicConstraint = cast<NPlugDyna_SKinematicConstraint>(nod);
        @this.spawnModel = cast<CPlugSpawnModel>(nod);
        @this.editorHelper = cast<CPlugEditorHelper>(nod);
        @this.sWaypoint = cast<NPlugTrigger_SWaypoint>(nod);
        @this.sSpecial = cast<NPlugTrigger_SSpecial>(nod);
        @this.cieModel = cast<CGameCommonItemEntityModel>(nod);
        @this.surf = cast<CPlugSurface>(nod);
        @this.s2m = cast<CPlugSolid2Model>(nod);
    }

    void ZeroFids() {
        MeshDuplication::ZeroFidsUnknownModelNod(nod);
    }

    void Draw() {
        if (nod is null) {
            UI::Text(name + " :: \\$f8fnull");
        } else if (so !is null) {
            Draw(so);
        } else if (prefab !is null) {
            Draw(prefab);
        } else if (varList !is null) {
            Draw(varList);
        } else if (fxSys !is null) {
            Draw(fxSys);
        } else if (vegetTree !is null) {
            Draw(vegetTree);
        } else if (dynaObject !is null) {
            Draw(dynaObject);
        } else if (kenematicConstraint !is null) {
            Draw(kenematicConstraint);
        } else if (spawnModel !is null) {
            Draw(spawnModel);
        } else if (editorHelper !is null) {
            Draw(editorHelper);
        } else if (sWaypoint !is null) {
            Draw(sWaypoint);
        } else if (sSpecial !is null) {
            Draw(sSpecial);
        } else if (cieModel !is null) {
            Draw(cieModel);
        } else if (s2m !is null) {
            Draw(s2m);
        } else if (surf !is null) {
            Draw(surf);
        } else {
            UI::Text("Unknown nod of type: " + UnkType(nod));
        }
    }


    void Draw(CPlugStaticObjectModel@ so) {
        if (StartTreeNode(name + " :: \\$f8fCPlugStaticObjectModel", UI::TreeNodeFlags::DefaultOpen)) {
            ItemModelTreeElement(so.Mesh, "Mesh").Draw();
            ItemModelTreeElement(so.Shape, "Shape").Draw();
            EndTreeNode();
        }
    }
    void Draw(CPlugPrefab@ prefab) {
        if (StartTreeNode(name + " :: \\$f8fCPlugPrefab", UI::TreeNodeFlags::DefaultOpen)) {
            UI::Text("nbEnts: " + prefab.Ents.Length);
            for (uint i = 0; i < prefab.Ents.Length; i++) {
                if (StartTreeNode(".Ents["+i+"]:", true)) {
                    UI::Text(".Location.Quat: " + prefab.Ents[i].Location.Quat.ToString());
                    UI::Text(".Location.Trans: " + prefab.Ents[i].Location.Trans.ToString());
                    DrawPrefabEntParams(prefab, i);
                    ItemModelTreeElement(prefab.Ents[i].Model, "Model").Draw();
                    if (prefab.Ents[i].Model is null && prefab.Ents[i].ModelFid !is null) {
                        UI::Text("\\$f80ModelFid without a Model: " + prefab.Ents[i].ModelFid.FileName);
                    }
                    EndTreeNode();
                }
            }
            EndTreeNode();
        }
    }
    void Draw(NPlugItem_SVariantList@ varList) {
        if (StartTreeNode(name + " :: \\$f8fNPlugItem_SVariantList", UI::TreeNodeFlags::DefaultOpen)) {
            UI::Text("nbVariants: " + varList.Variants.Length);
            for (uint i = 0; i < varList.Variants.Length; i++) {
                if (StartTreeNode(".Variant["+i+"]:", true)) {
                    UI::Text("nbPlacementTags: " + varList.Variants[i].Tags.Length + "  { " + GetVariantTagsStr(varList, i) + " }");
                    LabeledValue("HiddenInManualCycle: ", varList.Variants[i].HiddenInManualCycle);
                    ItemModelTreeElement(varList.Variants[i].EntityModel, "EntityModel").Draw();
                    EndTreeNode();
                }
            }
            EndTreeNode();
        }
    }

    string GetVariantTagsStr(NPlugItem_SVariantList@ varList, uint i) {
        string ret;
        auto vars = Dev::GetOffsetNod(varList, GetOffset(varList, "Variants"));
        auto tagsPtr = Dev::GetOffsetUint64(vars, 0x28 * i + GetOffset("NPlugItem_SVariant", "Tags"));
        for (uint t = 0; t < varList.Variants[i].Tags.Length; t++) {
            if (t > 0) ret += ", ";
            ret += "<" + tostring(Dev::ReadUInt32(tagsPtr + 0x8 * t))
                + ", " + tostring(Dev::ReadUInt32(tagsPtr + 0x8 * t + 0x4)) + ">";
        }
        return ret;
    }

    void Draw(CPlugFxSystem@ fxSys) {
        if (StartTreeNode(name + " :: \\$f8fCPlugFxSystem", UI::TreeNodeFlags::DefaultOpen)) {
            UI::Text("\\$f80todo");
            // fxSys. /*todo -- check variable declaration below.*/;
            auto tmp = fxSys;
            UI::Text("ContextClassId: " + tostring(tmp.ContextClassId));
            UI::Text("ExtraContextClassId: " + tostring(tmp.ExtraContextClassId));
            UI::Text("nbVars: " + tostring(tmp.Vars.Length));
            if (StartTreeNode("RootNode", true, UI::TreeNodeFlags::None)) {
                ItemModelTreeElement(fxSys.RootNode, "RootNode").Draw();
                EndTreeNode();
            }
            EndTreeNode();
        }
    }
    void Draw(CPlugVegetTreeModel@ vegetTree) {
        if (StartTreeNode(name + " :: \\$f8fCPlugVegetTreeModel", UI::TreeNodeFlags::DefaultOpen)) {
            auto tmp = vegetTree.Data;
            UI::Text("Impostor_Lod_Dist: " + tostring(tmp.Impostor_Lod_Dist));
            UI::Text("Impostor_Plane_Mode: " + tostring(tmp.Impostor_Plane_Mode));
            UI::Text("ReductionRatio01: " + tostring(tmp.ReductionRatio01)); /* Pourcentage max du scale random par instance. 0 = 100%, 0.3 = 70% (soyez raisonnable) */
            UI::Text("Params_AngleMax_RotXZ_Deg: " + tostring(tmp.Params_AngleMax_RotXZ_Deg));
            UI::Text("Params_EnableRandomRotationY: " + tostring(tmp.Params_EnableRandomRotationY));
            UI::TextDisabled("LodModels: UnknownType");// + tostring(tmp.LodModels));
            UI::TextDisabled("LodMaxDists: UnknownType");// + tostring(tmp.LodMaxDists));
            UI::TextDisabled("Materials: UnknownType");// + tostring(tmp.Materials));
            UI::Text("Params_Force_No_Collision: " + tostring(tmp.Params_Force_No_Collision));
            UI::Text("Params_Impostor_AllPlanesVisible: " + tostring(tmp.Params_Impostor_AllPlanesVisible));
            UI::Text("Params_ReceivesPSSM: " + tostring(tmp.Params_ReceivesPSSM));
            if (StartTreeNode("Propagation", true, UI::TreeNodeFlags::None)) {
                UI::Text("Propagation.Render_BaseColor?: " + tostring(tmp.Propagation.Render_BaseColor !is null));
                UI::Text("Propagation.Render_Normal?: " + tostring(tmp.Propagation.Render_Normal !is null));
                UI::Text("Propagation.Render_c2AtlasGrid: " + tostring(tmp.Propagation.Render_c2AtlasGrid));
                UI::Text("Propagation.Render_LeafSize: " + tostring(tmp.Propagation.Render_LeafSize));
                UI::Text("Propagation.Phy_cGroundGenPoint: " + tostring(tmp.Propagation.Phy_cGroundGenPoint));
                UI::Text("Propagation.Phy_cLeafPerSecond: " + tostring(tmp.Propagation.Phy_cLeafPerSecond));
                UI::Text("Propagation.Phy_ConeHalfAngleDeg: " + tostring(tmp.Propagation.Phy_ConeHalfAngleDeg));
                UI::Text("Propagation.Phy_EmissionSpawnRadius: " + tostring(tmp.Propagation.Phy_EmissionSpawnRadius));
                UI::Text("Propagation.Phy_Enable: " + tostring(tmp.Propagation.Phy_Enable));
                UI::TextDisabled("Propagation.EmissionPoss: Unknown Type");// + tostring(tmp.Propagation.EmissionPoss));
                EndTreeNode();
            }
            EndTreeNode();
        }
    }
    void Draw(CPlugDynaObjectModel@ dynaObject) {
        if (StartTreeNode(name + " :: \\$f8fCPlugDynaObjectModel", UI::TreeNodeFlags::DefaultOpen)) {
            ItemModelTreeElement(dynaObject.Mesh, "Mesh").Draw();
            ItemModelTreeElement(dynaObject.StaticShape, "StaticShape").Draw();
            ItemModelTreeElement(dynaObject.DynaShape, "DynaShape").Draw();
            EndTreeNode();
        }
    }
    void Draw(NPlugDyna_SKinematicConstraint@ kc) {
        if (StartTreeNode(name + " :: \\$f8fNPlugDyna_SKinematicConstraint", UI::TreeNodeFlags::DefaultOpen)) {
            auto tmp = kc;
            UI::Text("TransAxis: " + tostring(tmp.TransAxis));
            UI::Text("TransMin: " + tostring(tmp.TransMin));
            UI::Text("TransMax: " + tostring(tmp.TransMax));
            UI::Text("RotAxis: " + tostring(tmp.RotAxis));
            UI::Text("AngleMinDeg: " + tostring(tmp.AngleMinDeg));
            UI::Text("AngleMaxDeg: " + tostring(tmp.AngleMaxDeg));
            UI::Text("ShaderTcType: " + tostring(tmp.ShaderTcType));
            // print("ShaderTcAnimFunc: " + tostring(tmp.ShaderTcAnimFunc));
            // print("ShaderTcData_TransSub: " + tostring(tmp.ShaderTcData_TransSub));
            if (StartTreeNode("TransAnimFunc", true, UI::TreeNodeFlags::None)) {
                Draw_NPlugDyna_SAnimFunc01(kc, GetOffset(kc, "TransAnimFunc"));
                EndTreeNode();
            }
            if (StartTreeNode("RotAnimFunc", true, UI::TreeNodeFlags::None)) {
                Draw_NPlugDyna_SAnimFunc01(kc, GetOffset(kc, "RotAnimFunc"));
                EndTreeNode();
            }
            EndTreeNode();
        }
    }

    void Draw(CPlugSpawnModel@ spawnModel) {
        if (StartTreeNode(name + " :: \\$f8fCPlugSpawnModel", UI::TreeNodeFlags::DefaultOpen)) {
            UI::Text("DefaultGravitySpawn: " + spawnModel.DefaultGravitySpawn.ToString());
            UI::Text("Loc: " + FormatX::Iso4(spawnModel.Loc));
            UI::Text("TorqueDuration: " + spawnModel.TorqueDuration);
            UI::Text("TorqueX: " + spawnModel.TorqueX);
            EndTreeNode();
        }
    }
    void Draw(CPlugEditorHelper@ editorHelper) {
        if (StartTreeNode(name + " :: \\$f8fCPlugEditorHelper", UI::TreeNodeFlags::DefaultOpen)) {
            auto nod = editorHelper.PrefabFid is null ? null : editorHelper.PrefabFid.Nod;
            ItemModelTreeElement(nod, "PrefabFid.Nod").Draw();
            EndTreeNode();
        }
    }
    void Draw(NPlugTrigger_SWaypoint@ sWaypoint) {
        if (StartTreeNode(name + " :: \\$f8fNPlugTrigger_SWaypoint", UI::TreeNodeFlags::DefaultOpen)) {
            LabeledValue("NoRespawn", sWaypoint.NoRespawn);
            LabeledValue("sWaypoint.Type", tostring(sWaypoint.Type));
            ItemModelTreeElement(sWaypoint.TriggerShape, "TriggerShape").Draw();
            EndTreeNode();
        }
    }
    void Draw(NPlugTrigger_SSpecial@ sSpecial) {
        if (StartTreeNode(name + " :: \\$f8fNPlugTrigger_SSpecial", UI::TreeNodeFlags::DefaultOpen)) {
            ItemModelTreeElement(sSpecial.TriggerShape, "TriggerShape").Draw();
            EndTreeNode();
        }
    }
    void Draw(CGameCommonItemEntityModel@ cieModel) {
        if (StartTreeNode(name + " :: \\$f8fCGameCommonItemEntityModel", UI::TreeNodeFlags::DefaultOpen)) {
            ItemModelTreeElement(cieModel.StaticObject, "StaticObject").Draw();
            ItemModelTreeElement(cieModel.TriggerShape, "TriggerShape").Draw();
            ItemModelTreeElement(cieModel.PhyModel, "PhyModel").Draw();
            EndTreeNode();
        }
    }
    void Draw(CPlugSolid2Model@ s2m) {
        if (StartTreeNode(name + " :: \\$f8fCPlugSolid2Model", UI::TreeNodeFlags::DefaultOpen)) {
            CPlugSkel@ skel = cast<CPlugSkel>(Dev::GetOffsetNod(s2m, 0x78));
            uint nbVisualIndexedTriangles = Dev::GetOffsetUint32(s2m, 0xA8 + 0x8);
            uint nbMaterials = Dev::GetOffsetUint32(s2m, 0xC8 + 0x8);
            uint nbMaterialUserInsts = Dev::GetOffsetUint32(s2m, 0xF8 + 0x8);
            uint nbLights = Dev::GetOffsetUint32(s2m, 0x168 + 0x8);
            uint nbLightUserModels = Dev::GetOffsetUint32(s2m, 0x178 + 0x8);
            uint nbCustomMaterials = Dev::GetOffsetUint32(s2m, 0x1F8 + 0x8);
            UI::Text("nbVisualIndexedTriangles: " + nbVisualIndexedTriangles);
            UI::Text("nbMaterialUserInsts: " + nbMaterialUserInsts);
            UI::Text("nbLights: " + nbLights);
            UI::Text("nbLightUserModels: " + nbLightUserModels);
            DrawMaterialsAt("nbMaterials: " + nbMaterials, nod, 0xc8);
            DrawMaterialsAt("nbCustomMaterials: " + nbCustomMaterials, nod, 0x1F8);
            ItemModelTreeElement(skel, "Skel");
            EndTreeNode();
        }
    }

    void DrawMaterialsAt(const string &in title, CMwNod@ nod, uint16 offset) {
        if (StartTreeNode(title, true, UI::TreeNodeFlags::None)) {
            auto buf = Dev::GetOffsetNod(nod, offset);
            auto len = Dev::GetOffsetUint32(nod, offset + 0x8);
            for (uint i = 0; i < len; i++) {
                auto mat = cast<CPlugMaterial>(Dev::GetOffsetNod(buf, 0x8 * i));
                if (mat is null) {
                    UI::Text("" + i + ". null");
                } else {
                    auto fid = cast<CSystemFidFile>(Dev::GetOffsetNod(mat, 0x8));
                    if (fid is null) {
                        UI::Text("" + i + ". Unknown material.");
                    } else {
                        UI::Text("" + i + ". " + fid.FileName);
                    }
                }
            }
            EndTreeNode();
        }
    }


    void Draw(CPlugSurface@ surf) {
        if (StartTreeNode(name + " :: \\$f8fCPlugSurface", UI::TreeNodeFlags::DefaultOpen)) {
            DrawMaterialsAt("nbMaterials: " + surf.Materials.Length, surf, GetOffset(surf, "Materials"));
            UI::Text("MaterialIds.Length: " + surf.MaterialIds.Length);
            EndTreeNode();
        }
    }



    void Draw(CTrackMania@ asdf) {
        if (StartTreeNode(name + " :: \\$f8fCTrackMania", UI::TreeNodeFlags::DefaultOpen)) {
            UI::Text("\\$f80todo");
            EndTreeNode();
        }
    }

    bool StartTreeNode(const string &in title, UI::TreeNodeFlags flags = UI::TreeNodeFlags::DefaultOpen) {
        return StartTreeNode(title, false, flags);
    }

    bool StartTreeNode(const string &in title, bool suppressDev = false, UI::TreeNodeFlags flags = UI::TreeNodeFlags::DefaultOpen) {
        bool open = UI::TreeNode(title, flags);
        if (open) UI::PushID(title);
        if (open && !suppressDev && nod !is null) {
            auto fid = cast<CSystemFidFile>(Dev::GetOffsetNod(nod, 0x8));
#if SIG_DEVELOPER
            if (UX::SmallButton(Icons::Cube + " Explore Nod")) {
                ExploreNod(title, nod);
            }
//#if DEV
            UI::SameLine();
            CopiableLabeledValue("ptr", Text::FormatPointer(Dev_GetPointerForNod(nod)));
//#endif
            if (fid !is null) UI::SameLine();
#endif
            if (fid !is null) {
                UI::Text("\\$8f8Fid: " + fid.FileName);
            }
        }
        return open;
    }

    void EndTreeNode() {
        UI::PopID();
        UI::TreePop();
    }



    void DrawPrefabEntParams(CPlugPrefab@ prefab, uint i) {
        auto ents = Dev::GetOffsetNod(prefab, GetOffset("CPlugPrefab", "Ents"));
        // size: NPlugPrefab_SEntRef: 0x50
        auto ptr1 = Dev::GetOffsetUint64(ents, 0x50 * i + GetOffset("NPlugPrefab_SEntRef", "Params"));
        auto ptr2 = Dev::GetOffsetUint64(ents, 0x50 * i + GetOffset("NPlugPrefab_SEntRef", "Params") + 0x8);
        string type = "Unknown";
        uint32 paramsClsId;
        if (ptr2 > 0 && ptr2 % 8 == 0) {
            type = Dev::ReadCString(Dev::ReadUInt64(ptr2));
            paramsClsId = Dev::ReadUInt32(ptr2 + 0x10);
            if (StartTreeNode("\\$888Params: ClsId / Type: " + Text::Format("%08x / " + type, paramsClsId),
                true, UI::TreeNodeFlags::None
            )) {
                DrawSMetaPtr(ptr1, paramsClsId);
                EndTreeNode();
            }
            // uint nextTypeMetadataEntry = Dev::ReadUInt64(ptr2 + 0x20);
            // if (entInfoPtr > 0 && entInfoPtr % 8 == 0) {
            //     entType = Dev::ReadCString(Dev::ReadUInt64(entInfoPtr + 0x8));
            //     entClsId = Dev::ReadUInt32(entInfoPtr + 0x18);
            //     UI::TextDisabled("ClsId / Type: " + Text::Format("%08x / " + entType, entClsId));
            // }
        }
    }
}




uint64 Dev_GetPointerForNod(CMwNod@ nod) {
    if (nod is null) throw('nod was null');
    auto tmpNod = CMwNod();
    uint64 tmp = Dev::GetOffsetUint64(tmpNod, 0);
    Dev::SetOffset(tmpNod, 0, nod);
    uint64 ptr = Dev::GetOffsetUint64(tmpNod, 0);
    Dev::SetOffset(tmpNod, 0, tmp);
    return ptr;
}




string UnkType(CMwNod@ nod) {
    if (nod is null) return "null";
    return Reflection::TypeOf(nod).Name;
}



void DrawSMetaPtr(uint64 ptr, uint32 clsId) {
    if (clsId == 0) return;
    auto ty = Reflection::GetType(clsId);
    if (ty is null) return;
    uint16 maxOffset = 0;
    for (uint i = 0; i < ty.Members.Length; i++) {
        auto mem = ty.Members[i];
        if (mem.Offset < 0xFFFF && mem.Offset > maxOffset) {
            maxOffset = mem.Offset;
        }
    }
    // add a bit, unlikely to get into unallocated memory.
    maxOffset += 0x8;
#if SIG_DEVELOPER
    CopiableLabeledValue("\\$888Ptr", Text::FormatPointer(ptr));
#endif
    CopiableLabeledValue("\\$888Data", Dev::Read(ptr, maxOffset));
}


void Draw_NPlugDyna_SAnimFunc01(CMwNod@ nod, uint16 offset) {
    auto len = Dev::GetOffsetUint32(nod, offset);
    auto startOffset = offset + 0x4;
    for (uint i = 0; i < len; i++) {
        // each subfunc is 0x8 long
        auto sfOffset = startOffset + 0x8 * i;
        auto type = SubFuncEasings(Dev::GetOffsetUint8(nod, sfOffset));
        auto reverse = Dev::GetOffsetUint8(nod, sfOffset + 0x1) == 1;
        auto duration = Dev::GetOffsetUint32(nod, sfOffset + 0x4);
        UI::Text(tostring(type) + ", Rev: " + reverse + ", Duration: " + duration);
    }
}





class ItemModelBrowserTab : Tab {
    ItemModelBrowserTab(TabGroup@ p) {
        super(p, "Model Browser", "");
    }

    CGameItemModel@ GetItemModel() {
        if (selectedItemModel is null) return null;
        return selectedItemModel.AsItemModel();
    }

    void DrawInner() override {
        auto item = GetItemModel();
        if (item is null) {
            UI::Text("No item.");
            return;
        }
        ItemModel(item).DrawTree();
    }
}

class IE_ItemModelBrowserTab : ItemModelBrowserTab {
    IE_ItemModelBrowserTab(TabGroup@ p) {
        super(p);
    }

    CGameItemModel@ GetItemModel() override {
        auto ieditor = cast<CGameEditorItem>(GetApp().Editor);
        return ieditor.ItemModel;
    }
}
