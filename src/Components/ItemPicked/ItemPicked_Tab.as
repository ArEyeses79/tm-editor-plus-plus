class FocusedItemTab : Tab, NudgeItemBlock {
    private ReferencedNod@ pinnedItem;

    FocusedItemTab(TabGroup@ parent, const string &in name) {
        super(parent, name, Icons::Crosshairs + Icons::Cube);
        removable = true;
    }

    ReferencedNod@ get_FocusedItem() {
        return pinnedItem;
    }

    void set_FocusedItem(ReferencedNod@ value) {
        @pinnedItem = value;
    }

    private bool showHelpers = true;
    bool get_ShowHelpers() {
        return showHelpers;
    }
    void set_ShowHelpers(bool value) {
        showHelpers = value;
    }

    private bool showItemBox = true;
    bool get_ShowItemBox() {
        return showItemBox;
    }
    void set_ShowItemBox(bool value) {
        showItemBox = value;
    }

    protected bool m_ItemChanged = false;
    float cursorCoordHelpersSize = 10.;

    string nullItemError = "No item.";

    void DrawInner() override {
        CGameCtnEditorFree@ editor = cast<CGameCtnEditorFree>(GetApp().Editor);
        if (FocusedItem is null || FocusedItem.AsItem() is null || editor is null) {
            UI::Text(nullItemError);
            return;
        }
        auto item = FocusedItem.AsItem();


        CopiableLabeledValue("Name", item.ItemModel.IdName);
        CopiableLabeledValue("Pos", item.AbsolutePositionInMap.ToString());
        CopiableLabeledValue("P,Y,R (Rad)", Editor::GetItemRotation(item).ToString());
        CopiableLabeledValue("Coord", item.BlockUnitCoord.ToString());
        auto assocBlock = Editor::GetItemsBlockAssociation(item);
        if (int(item.BlockUnitCoord.x) < 0 && assocBlock is null) {
            if (UI::Button("Fix block unit coord")) {
                item.BlockUnitCoord = PosToCoord(item.AbsolutePositionInMap);
            }
        }
        if (assocBlock is null) {
            UI::TextDisabled("No associated block.");
        } else {
            if (UI::CollapsingHeader("Associated Block")) {
                UI::Indent();
                CopiableLabeledValue("Name", assocBlock.DescId.GetName());
                CopiableLabeledValue("Coord", assocBlock.Coord.ToString());
                if (UI::Button("Remove Association")) {
                    Editor::DissociateItem(item);
                }
                UI::Unindent();
            }
        }
        UI::Separator();

        if (ShowHelpers) {
            nvgCircleWorldPos(item.AbsolutePositionInMap);
            nvg::StrokeColor(vec4(0, 1, 1, 1));
            nvg::StrokeWidth(3);
            nvg::Stroke();
            nvgToWorldPos(item.AbsolutePositionInMap);
            nvgDrawCoordHelpers(Editor::GetItemMatrix(item), cursorCoordHelpersSize);
        }

        ShowHelpers = UI::Checkbox("Draw Item Rot Helper", ShowHelpers);
        cursorCoordHelpersSize = UI::InputFloat("Rot Helpers Size", cursorCoordHelpersSize);

        UI::Separator();

        UI::AlignTextToFramePadding();
        UI::Text("Edit Picked Item Properties (Helper dot shows position)");

        vec3 initPos = item.AbsolutePositionInMap;
        vec3 initRot = Editor::GetItemRotation(item);
        auto initColor = item.MapElemColor;
        auto initFlying = item.IsFlying;
        auto initIVar = item.IVariant;

        item.AbsolutePositionInMap = UI::InputFloat3("Pos.##picked-item-pos", item.AbsolutePositionInMap);

        vec3 outRot = UX::InputAngles3("Rot (Deg)##picked-item-rot", initRot);
        Editor::SetItemRotation(item, outRot);

        item.MapElemColor = DrawEnumColorChooser(item.MapElemColor);

        item.IsFlying = UI::Checkbox("Is Flying", item.IsFlying);
        DrawEditVariants(item);

        auto skipForceRefresh = initColor != item.MapElemColor
            || !Math::Vec3Eq(initPos, item.AbsolutePositionInMap)
            || !Math::Vec3Eq(initRot, outRot);

        auto changed = skipForceRefresh
            || initFlying != item.IsFlying
            || initIVar != item.IVariant
            ;

        if (changed) {
            @item = Editor::RefreshSingleItemAfterModified(editor, item, !skipForceRefresh);
            @FocusedItem = ReferencedNod(item);
            // if (!skipForceRefresh)
            //     RotateItemColorForRefresh(editor, item);
            // // auto col = item.MapElemColor;
            // // item.MapElemColor = CGameCtnAnchoredObject::EMapElemColor::Red;
            // // item.MapElemColor = CGameCtnAnchoredObject::EMapElemColor::Blue;
            // // item.MapElemColor = col;
            // auto nbRefs = Reflection::GetRefCount(item);
            // auto lastItem = editor.Challenge.AnchoredObjects[editor.Challenge.AnchoredObjects.Length - 1];
            // trace('last item ref count: ' + Reflection::GetRefCount(lastItem));
            // trace('nb item: ' + editor.Challenge.AnchoredObjects.Length + ', ' + nbRefs);
            // Editor::RefreshBlocksAndItems(editor);
            // trace('nb item: ' + editor.Challenge.AnchoredObjects.Length + ', ' + Reflection::GetRefCount(item));
            // @lastItem = editor.Challenge.AnchoredObjects[editor.Challenge.AnchoredObjects.Length - 1];
            // trace('last item ref count: ' + Reflection::GetRefCount(lastItem));
            // if (nbRefs != Reflection::GetRefCount(item)) {
            //     @FocusedItem = ReferencedNod(Editor::FindReplacementItemAfterUpdate(editor, item));
            //     if (!skipForceRefresh)
            //         @FocusedItem = ReferencedNod(RestoreItemColorAfterRefresh(editor, FocusedItem.AsItem()));
            //     @item = FocusedItem.AsItem();
            // } else {
            //     trace('item ref count didnt change: ' + nbRefs);
            // }
            // @lastItem = editor.Challenge.AnchoredObjects[editor.Challenge.AnchoredObjects.Length - 1];
            // trace('last item ref count: ' + Reflection::GetRefCount(lastItem));
        }

        // if (UI::Button("Refresh All##items")) {
        //     auto nbRefs = Reflection::GetRefCount(item);
        //     Editor::RefreshBlocksAndItems(editor);
        //     if (nbRefs != Reflection::GetRefCount(item)) {
        //         @lastPickedItem = ReferencedNod(editor.Challenge.AnchoredObjects[editor.Challenge.AnchoredObjects.Length - 1]);
        //         UpdatePickedItemCachedValues();
        //         @item = lastPickedItem.AsItem();
        //     }
        // }

        UI::Separator();

        UI::AlignTextToFramePadding();
        UI::Text("Nudge Picked Item:");

        DrawNudgeFor(item);

        UI::Separator();
        if (UI::CollapsingHeader("Relative/Absolute Position Calculator (useful for static respawns)")) {
            UI::Indent();

            UI::Text("Absolute to Relative");
            m_Calc_AbsPosition = UI::InputFloat3("Abs.", m_Calc_AbsPosition);
            UI::SameLine();
            if (UI::Button("Reset###clac-abs-position")) {
                m_Calc_AbsPosition = vec3();
            }
            auto m = Editor::GetItemMatrix(item);
            vec3 relPos = (mat4::Inverse(m) * m_Calc_AbsPosition).xyz;
            CopiableLabeledValue("Relative Position", relPos.ToString());

            UI::Separator();
            UI::Text("Relative to Absolute");

            m_Calc_RelPosition = UI::InputFloat3("Rel.", m_Calc_RelPosition);
            UI::SameLine();
            if (UI::Button("Reset###clac-rel-position")) {
                m_Calc_RelPosition = vec3();
            }
            vec3 absPos = (m * m_Calc_RelPosition).xyz;
            CopiableLabeledValue("Absolute Position", absPos.ToString());

            UI::Unindent();
        }
    }

    void DrawEditVariants(CGameCtnAnchoredObject@ item) {
        // auto commonItemEntModel = cast<CGameCommonItemEntityModel>(item.ItemModel.EntityModel);
        auto variantList = cast<NPlugItem_SVariantList>(item.ItemModel.EntityModel);
        if (variantList !is null) {
            auto nbVars = variantList.Variants.Length;
            item.IVariant = Math::Clamp(UI::InputInt("Variant", item.IVariant), 0, nbVars - 1);

            auto currVar = variantList.Variants[item.IVariant];
            string fileName = currVar.EntityModelFidForReload !is null ? string(currVar.EntityModelFidForReload.FileName) : "??";

            LabeledValue("Nb Variants", nbVars);
            UI::SameLine();
            LabeledValue("Current", fileName);

            if (UI::CollapsingHeader("Variant Details")) {
                for (uint i = 0; i < variantList.Variants.Length; i++) {
                    DrawVariantInfo(i, variantList.Variants[i]);
                }
            }
        }
    }

    void DrawVariantInfo(uint ix, NPlugItem_SVariant@ variant) {
        UI::AlignTextToFramePadding();
        string fileName = variant.EntityModelFidForReload !is null ? string(variant.EntityModelFidForReload.FileName) : "??";
        string msg = fileName + " :: ";
        msg += variant.EntityModel !is null ? Reflection::TypeOf(variant.EntityModel).Name : "null?";
        UI::Text("" + ix + ". " + msg);
        UI::SameLine();
        variant.HiddenInManualCycle = UI::Checkbox("##.HiddenInManualCycle"+fileName, variant.HiddenInManualCycle);
        AddSimpleTooltip(".HiddenInManualCycle");
    }

    vec3 m_Calc_AbsPosition = vec3();
    vec3 m_Calc_RelPosition = vec3();
}

class PickedItemTab : FocusedItemTab {
    PickedItemTab(TabGroup@ parent) {
        super(parent, "Picked Item");
        removable = false;
        nullItemError = "No picked Item. Ctrl+Hover to pick a Item.";
    }

    bool get_ShowHelpers() override property {
        return S_DrawPickedItemHelpers;
    }

    void set_ShowHelpers(bool value) override property {
        S_DrawPickedItemHelpers = value;
    }

    ReferencedNod@ get_FocusedItem() override property {
        return lastPickedItem;
    }

    void set_FocusedItem(ReferencedNod@ value) override property {
        @lastPickedItem = value;
        UpdatePickedItemCachedValues();
    }
}

class PinnedItemTab : FocusedItemTab {
    PinnedItemTab(TabGroup@ parent, CGameCtnAnchoredObject@ Item) {
        super(parent, Item.ItemModel.Name + "@" + Item.AbsolutePositionInMap.ToString());
        @FocusedItem = ReferencedNod(Item);
    }
}
