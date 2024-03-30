ViewDuplicateFreeBlocksTab@ g_DuplicateFreeBlocks_SubTab;

class BI_MainTab : Tab {
    BI_MainTab(TabGroup@ p) {
        super(p, "Blocks & Items", Icons::Cubes + Icons::Tree);
        canPopOut = false;
        ViewAllBlocksTab(Children);
        ViewAllBlocksTab(Children, true);
        ViewSkinnedBlocksTab(Children);
        ViewAllItemsTab(Children);
        ViewSkinnedItemsTab(Children);
        ViewClassicBlocksTab(Children);
        ViewGhostBlocksTab(Children);
        @g_DuplicateFreeBlocks_SubTab = ViewDuplicateFreeBlocksTab(Children);
        WaypointsBITab(Children);
        MacroblocksBITab(Children);
        // ViewKinematicsTab(Children);
    }

    void DrawInner() override {
        Children.DrawTabs();
    }
}

class ViewClassicBlocksTab : ViewAllBlocksTab {
    ViewClassicBlocksTab(TabGroup@ p) {
        super(p, "Classic Blocks", Icons::Cubes, BIListTabType::Blocks);
        nbCols = 9;
    }

    uint GetNbObjects(CGameCtnChallenge@ map) override {
        auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
        return editor.PluginMapType.ClassicBlocks.Length;
    }

    CGameCtnBlock@ GetBlock(CGameCtnChallenge@ map, uint i) override {
        auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
        return editor.PluginMapType.ClassicBlocks[i];
    }
}

class ViewGhostBlocksTab : ViewAllBlocksTab {
    ViewGhostBlocksTab(TabGroup@ p) {
        super(p, "Ghost Blocks", Icons::Cubes, BIListTabType::Blocks);
        nbCols = 9;
    }

    uint GetNbObjects(CGameCtnChallenge@ map) override {
        auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
        return editor.PluginMapType.GhostBlocks.Length;
    }

    CGameCtnBlock@ GetBlock(CGameCtnChallenge@ map, uint i) override {
        auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
        return editor.PluginMapType.GhostBlocks[i];
    }
}

class ViewSkinnedBlocksTab : ViewAllBlocksTab {
    ViewSkinnedBlocksTab(TabGroup@ p) {
        super(p, "Skinned Blocks", Icons::Cubes, BIListTabType::Blocks);
        nbCols = 9;
    }


    void DrawInnerEarly() override {
        UI::Text("To update list: Caches > Refresh Map Block/Item Cache");
    }

    uint GetNbObjects(CGameCtnChallenge@ map) override {
        return Editor::GetMapCache().SkinnedBlocks.Length;
    }

    CGameCtnBlock@ GetBlock(CGameCtnChallenge@ map, uint i) override {
        auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
        return Editor::GetMapCache().SkinnedBlocks[i].FindMe(editor.PluginMapType);
    }
}


class ViewAllBlocksTab : BlockItemListTab {
    ViewAllBlocksTab(TabGroup@ p, bool isBaked = false) {
        super(p, isBaked ? "All Baked Blocks " : "All Blocks", Icons::Cubes, isBaked ? BIListTabType::BakedBlocks : BIListTabType::Blocks);
        nbCols = 9;
    }

    // Passthrough constructor
    ViewAllBlocksTab(TabGroup@ p, const string &in title, const string &in icon, BIListTabType ty) {
        super(p, title, icon, ty);
        nbCols = 9;
    }

    void SetupMainTableColumns(bool offsetScrollbar = false) override {
        float bigNumberColWidth = 110;
        float numberColWidth = 90;
        float smlNumberColWidth = 70;
        float exploreColWidth = numberColWidth + (offsetScrollbar ? UI::GetStyleVarFloat(UI::StyleVar::ScrollbarSize) : 0.);
        UI::TableSetupColumn("#", UI::TableColumnFlags::WidthFixed, 50.);
        UI::TableSetupColumn("Type", UI::TableColumnFlags::WidthStretch);
        UI::TableSetupColumn("Pos", UI::TableColumnFlags::WidthFixed, bigNumberColWidth);
        UI::TableSetupColumn("Coord", UI::TableColumnFlags::WidthFixed, bigNumberColWidth);
        UI::TableSetupColumn("Dir", UI::TableColumnFlags::WidthFixed, smlNumberColWidth);
        UI::TableSetupColumn("Color", UI::TableColumnFlags::WidthFixed, smlNumberColWidth);
        UI::TableSetupColumn("LM", UI::TableColumnFlags::WidthFixed, smlNumberColWidth);
        UI::TableSetupColumn("Is CP", UI::TableColumnFlags::WidthFixed, smlNumberColWidth);
        UI::TableSetupColumn("Tools", UI::TableColumnFlags::WidthFixed, exploreColWidth);
    }

    void DrawObjectInfo(CGameCtnChallenge@ map, int i) override {
        UI::TableNextRow();
        auto block = GetBlock(map, i);

        if (block is null) {
            UI::TableNextColumn();
            UI::Text("<null>");
            return;
        }

        auto blockId = Editor::GetBlockUniqueID(block);

        UI::TableNextColumn();
        UI::Text(tostring(i));

        UI::TableNextColumn();
        UI::Text(block.DescId.GetName());
        auto rowHovered = UI::IsItemHovered();
        if (rowHovered) {
            auto m = Editor::GetBlockMatrix(block);
            nvgDrawBlockBox(m, Editor::GetBlockSize(block), cOrange);
            nvgDrawBlockBox(m, vec3(32, 8, 32), cOrange);
        }

        UI::TableNextColumn();
        UI::Text(FormatX::Vec3(Editor::GetBlockLocation(block)));

        UI::TableNextColumn();
        UI::Text(FormatX::Nat3(block.Coord));

        UI::TableNextColumn();
        UI::Text(tostring(block.BlockDir));

        UI::TableNextColumn();
        UI::Text(tostring(block.MapElemColor));

        UI::TableNextColumn();
        UI::Text(tostring(block.MapElemLmQuality));

        UI::TableNextColumn();
        UI::Text(GetCpMark(block.BlockInfo.WaypointType));

        UI::TableNextColumn();
        if (UX::SmallButton(Icons::Eye + "##" + blockId)) {
            auto pos = Editor::GetCtnBlockMidpoint(block);
            Editor::SetCamAnimationGoTo(Editor::DirToLookUvFromCamera(pos), pos, 120.);
        }
        UI::SameLine();
        if (UX::SmallButton(Icons::MapMarker + "##" + blockId)) {
            Notify("Setting block ("+blockId+") as picked item.");
            g_PickedBlockTab.SetSelectedTab();
            @lastPickedBlock = ReferencedNod(block);
            UpdatePickedBlockCachedValues();
        }
        if (!Editor::IsBlockFree(block)) {
            UI::SameLine();
            if (UX::SmallButton(Icons::TrashO + "##" + blockId)) {
                startnew(CoroutineFuncUserdata(DeleteBlockSoon), block);
            }
        }
    }

    void DeleteBlockSoon(ref@ ref) {
        CGameCtnBlock@ block = cast<CGameCtnBlock>(ref);
        if (block is null) return;
        auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
        editor.PluginMapType.AutoSave();
        if (block.IsGhostBlock()) {
            if (!editor.PluginMapType.RemoveGhostBlock(block.BlockInfo, Nat3ToInt3(block.Coord), block.Dir)) {
                NotifyWarning("Unable to remove ghost block:\n Coord: " + block.Coord.ToString() + "\n Type: " + block.DescId.GetName() + "\n: Dir: " + tostring(block.Dir));
            }
        } else {
            if (!editor.PluginMapType.RemoveBlock(Nat3ToInt3(block.Coord))) {
                NotifyWarning("Unable to remove block at " + block.Coord.ToString());
            }
        }
    }
}

class ViewAllItemsTab : BlockItemListTab {
    ViewAllItemsTab(TabGroup@ p) {
        super(p, "All Items", Icons::Tree, BIListTabType::Items);
        nbCols = 8;
    }

    // Passthrough constructor
    ViewAllItemsTab(TabGroup@ p, const string &in title, const string &in icon, BIListTabType ty) {
        super(p, title, icon, ty);
        nbCols = 8;
    }

    void SetupMainTableColumns(bool offsetScrollbar = false) override {
        float bigNumberColWidth = 110;
        float stdNumberColWidth = 90;
        float smlNumberColWidth = 70;
        float exploreColWidth = stdNumberColWidth + (offsetScrollbar ? UI::GetStyleVarFloat(UI::StyleVar::ScrollbarSize) : 0.);
        UI::TableSetupColumn("#", UI::TableColumnFlags::WidthFixed, 50.);
        UI::TableSetupColumn("Type", UI::TableColumnFlags::WidthStretch);
        UI::TableSetupColumn("Pos", UI::TableColumnFlags::WidthFixed, bigNumberColWidth);
        UI::TableSetupColumn("Rot", UI::TableColumnFlags::WidthFixed, bigNumberColWidth);
        UI::TableSetupColumn("Color", UI::TableColumnFlags::WidthFixed, smlNumberColWidth);
        UI::TableSetupColumn("LM", UI::TableColumnFlags::WidthFixed, smlNumberColWidth);
        UI::TableSetupColumn("Is CP", UI::TableColumnFlags::WidthFixed, smlNumberColWidth);
        UI::TableSetupColumn("Tools", UI::TableColumnFlags::WidthFixed, exploreColWidth);
    }

    void DrawObjectInfo(CGameCtnChallenge@ map, int i) override {
        UI::TableNextRow();
        auto item = GetItem(map, i);
        if (item is null) {
            UI::TableNextColumn();
            UI::Text("<null>");
            return;
        }

        auto blockId = Editor::GetItemUniqueBlockID(item);


        UI::TableNextColumn();
        UI::Text(tostring(i));

        UI::TableNextColumn();
        UI::Text(item.ItemModel.IdName);

        UI::TableNextColumn();
        UI::Text(FormatX::Vec3(item.AbsolutePositionInMap));

        UI::TableNextColumn();
        UI::Text(FormatX::Vec3(MathX::ToDeg(Editor::GetItemRotation(item))));

        UI::TableNextColumn();
        UI::Text(tostring(item.MapElemColor));

        UI::TableNextColumn();
        UI::Text(tostring(item.MapElemLmQuality));

        UI::TableNextColumn();
        UI::Text(GetCpMark(item.ItemModel.WaypointType));

        UI::TableNextColumn();
        if (UX::SmallButton(Icons::Eye + "##" + blockId)) {
            Editor::SetCamAnimationGoTo(Editor::DirToLookUvFromCamera(item.AbsolutePositionInMap), item.AbsolutePositionInMap, 120.);
        }
        UI::SameLine();
        if (UX::SmallButton(Icons::MapMarker + "##" + blockId)) {
            Notify("Setting item ("+blockId+") as picked item.");
            @lastPickedItem = ReferencedNod(item);
            g_PickedItemTab.SetSelectedTab();
            UpdatePickedItemCachedValues();
        }
        // // todo: not sure how to do item removal
        // UI::SameLine();
        // if (UX::SmallButton(Icons::TrashO + "##" + blockId)) {
        //     startnew(CoroutineFuncUserdata(_RemoveItemLater), map);
        //     _removeIx = i;
        //     // map.AnchoredObjects.Remove(i);
        //     // auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
        //     // Editor::UpdateNewlyAddedItems(editor);
        //     // Editor::RefreshBlocksAndItems();
        // }
    }

    // uint _removeIx = 0;
    // void _RemoveItemLater(ref@ _r) {
    //     auto map = cast<CGameCtnChallenge>(_r);
    //     auto item = map.AnchoredObjects[_removeIx];
    //     map.AnchoredObjects.Remove(_removeIx);
    //     item.MwRelease();
    // }
}


class ViewSkinnedItemsTab : ViewAllItemsTab {
    ViewSkinnedItemsTab(TabGroup@ p) {
        super(p, "Skinned Items", Icons::Tree, BIListTabType::Items);
    }

    void DrawInnerEarly() override {
        UI::Text("To update list: Caches > Refresh Map Block/Item Cache");
    }

    uint GetNbObjects(CGameCtnChallenge@ map) override {
        return Editor::GetMapCache().SkinnedItems.Length;
    }

    CGameCtnAnchoredObject@ GetItem(CGameCtnChallenge@ map, uint i) override {
        auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
        return Editor::GetMapCache().SkinnedItems[i].FindMe(editor.PluginMapType);
    }
}

class ViewDuplicateFreeBlocksTab : ViewAllBlocksTab {
    ViewDuplicateFreeBlocksTab(TabGroup@ p) {
        super(p, "Dup. Blks", Icons::Cubes, BIListTabType::Blocks);
        nbCols = 9;
    }

    uint GetNbObjects(CGameCtnChallenge@ map) override {
        return (Editor::GetMapCache()).DuplicateBlocks.Length;
    }

    CGameCtnBlock@ GetBlock(CGameCtnChallenge@ map, uint i) override {
        auto mapCache = Editor::GetMapCache();
        auto cacheBlock = mapCache.DuplicateBlocks[i];
        auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
        return cacheBlock.FindMe(editor.PluginMapType);
    }

    BlockPlacementType[] m_Priorities = {BlockPlacementType::Normal, BlockPlacementType::Ghost, BlockPlacementType::Free};
    bool m_RefreshCacheFirst = true;

    void DrawInnerEarly() override {
        if (UI::Button("Refresh Cache##refresh-cache-dup-blks")) {
            Editor::GetMapCache().RefreshCacheSoon();
        }
        UI::Separator();
        UI::AlignTextToFramePadding();
        UI::Text("Autoremove duplicates:");
        DrawPriorityForm();
    }

    void DrawPriorityForm() {
        UI::Indent();
        UI::Text("Priority: (Keep first matching highest)");
        UI::Indent();
        for (uint i = 0; i < m_Priorities.Length; i++) {
            UI::Text(tostring(i + 1) + ". " + tostring(m_Priorities[i]));
            UI::SameLine();
            if (UX::SmallButtonMbDisabled(Icons::ArrowUp + "##up-" + i, "Higher Priority", i == 0)) {
                auto tmp = m_Priorities[i];
                m_Priorities[i] = m_Priorities[i - 1];
                m_Priorities[i - 1] = tmp;
            }
            UI::SameLine();
            if (UX::SmallButtonMbDisabled(Icons::ArrowDown + "##down-" + i, "Lower Priority", i == m_Priorities.Length - 1)) {
                auto tmp = m_Priorities[i];
                m_Priorities[i] = m_Priorities[i + 1];
                m_Priorities[i + 1] = tmp;
            }
        }
        UI::Unindent();
        if (UI::Button("Run Autodeletion")) {
            startnew(CoroutineFunc(this.RunAutodeletion));
        }
        // m_RefreshCacheFirst = UI::Checkbox("Refresh Cache First", m_RefreshCacheFirst);
        UI::Unindent();
    }

    void DrawAutoremoveDuplicatesMenu() {
        auto mapCache = Editor::GetMapCache();
        auto nbDupes = mapCache.DuplicateBlocks.Length;
        UI::BeginDisabled(nbDupes == 0);
        if (UI::BeginMenu("Autoremove Duplicates ("+nbDupes+")##autoremove-dup-blks-menu")) {
            DrawPriorityForm();
            UI::EndMenu();
        }
        UI::EndDisabled();
    }

    void RunAutodeletion() {
        auto mapCache = Editor::GetMapCache();
        if (mapCache.IsStale) {
            Notify("[Autodel Dups] 0. Map cache stale, refreshing.");
            mapCache.RefreshCache();
            // Notify("[Autodel Dups] 0. Map cache refreshed.");
        }
        auto nbDupes = mapCache.DuplicateBlocks.Length;
        if (nbDupes == 0) {
            Notify("Autodel Dups] 1. No duplicates found.");
            return;
        }
        Notify("[Autodel Dups] 1. Starting autodeletion of " + nbDupes + " duplicates.");

        auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
        auto pmt = editor.PluginMapType;

        Editor::BlockSpec@[]@ mbBlocks = {};
        auto mbSpec = Editor::MakeMacroblockSpec(mbBlocks, {});

        // loop through lists in mapCache.DuplicateBlockKeys
        for (uint i = 0; i < mapCache.DuplicateBlockKeys.Length; i++) {
            auto k = mapCache.DuplicateBlockKeys[i];
            auto @blocks = mapCache.GetBlocksByHash(k);
            if (blocks.Length < 2) {
                NotifyWarning("[Autodel Dups] 2. Unexpected: key " + k + " has length " + blocks.Length);
                continue;
            }
            mbSpec.AddBlocks(GetDuplicateBlocksLowestPriority(pmt, blocks));
        }

        Notify("[Autodel Dups] 3. Deleting " + mbSpec.Blocks.Length + " blocks.");
        Editor::DeleteMacroblock(mbSpec, true);
        startnew(Editor::RunDeleteFreeBlockDetection).WithRunContext(Meta::RunContext::MainLoop);
        yield();
        Notify("[Autodel Dups] 3. Deleted " + mbSpec.Blocks.Length + " blocks. Refreshing cache.");
        Editor::GetMapCache().RefreshCacheSoon();
    }

    CGameCtnBlock@[]@ GetDuplicateBlocksLowestPriority(CGameEditorPluginMapMapType@ pmt, Editor::BlockInMap@[]@ blocks) {
        CGameCtnBlock@[]@ ret = {};
        CGameCtnBlock@ keep = null;
        int keepIx = -1;
        BlockPlacementType bestTyFound = BlockPlacementType::Normal;
        int bestTyIx = -1;
        for (uint i = 0; i < blocks.Length; i++) {
            auto b = blocks[i];
            if (keep is null || bestTyIx == -1 || m_Priorities.Find(b.PlacementTy) < bestTyIx) {
                @keep = b.FindMe(pmt);
                keepIx = i;
                bestTyFound = b.PlacementTy;
                bestTyIx = m_Priorities.Find(b.PlacementTy);
                // did we find a block with the highest priority?
                if (bestTyIx == 0) break;
            }
            if (bestTyIx < 0) throw("Should never be -1 after 1st loop (bestTyIx)");
            if (keepIx < 0) throw("Should never be -1 after 1st loop (keepIx)");
        }
        for (uint i = 0; i < blocks.Length; i++) {
            if (i == keepIx) continue;
            auto b = blocks[i];
            auto block = b.FindMe(pmt);
            if (block is null) continue;
            ret.InsertLast(block);
        }
        return ret;
    }
}

class WaypointsBITab : Tab {
    WaypointsBITab(TabGroup@ p) {
        super(p, "Waypoints", Icons::FlagCheckered);
        WaypointBlocksTab(Children);
        WaypointItemsTab(Children);
    }

    void DrawInner() override {
        UI::Text("To refresh: Caches > Refresh Map Block/Item Cache");
        Children.DrawTabs();
    }
}

class WaypointBlocksTab : ViewAllBlocksTab {
    WaypointBlocksTab(TabGroup@ p) {
        super(p, "Wp Blocks", Icons::Cubes + Icons::FlagCheckered, BIListTabType::Blocks);
        nbCols = 9;
    }

    uint GetNbObjects(CGameCtnChallenge@ map) override {
        return (Editor::GetMapCache()).WaypointBlocks.Length;
    }

    CGameCtnBlock@ GetBlock(CGameCtnChallenge@ map, uint i) override {
        auto mapCache = Editor::GetMapCache();
        auto cacheBlock = mapCache.WaypointBlocks[i];
        auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
        return cacheBlock.FindMe(editor.PluginMapType);
    }
}

class WaypointItemsTab : ViewAllItemsTab {
    WaypointItemsTab(TabGroup@ p) {
        super(p, "Wp Items", Icons::Tree + Icons::FlagCheckered, BIListTabType::Items);
    }

    uint GetNbObjects(CGameCtnChallenge@ map) override {
        return (Editor::GetMapCache()).WaypointItems.Length;
    }

    CGameCtnAnchoredObject@ GetItem(CGameCtnChallenge@ map, uint i) override {
        auto mapCache = Editor::GetMapCache();
        auto cacheItem = mapCache.WaypointItems[i];
        auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
        return cacheItem.FindMe(editor.PluginMapType);
    }
}

class MacroblocksBITab : Tab {
    MacroblocksBITab(TabGroup@ p) {
        super(p, "Macroblocks", Icons::Cubes + Icons::Tree);
    }

    void DrawInner() override {
        auto map = GetApp().RootMap;
        if (map is null) return;
        UI::Text("To refresh: Caches > Refresh Map Block/Item Cache");
        auto mbs = Editor::GetMapMacroblocks(map);
        if (mbs.Length == 0) {
            UI::Text("No macroblocks found.");
            return;
        }
        auto mapCache = Editor::GetMapCache();
        auto @mbCache = mapCache.Macroblocks;
        Editor::ObjInMap@ obj;
        array<Editor::ObjInMap@>@ objs;
        for (uint i = 0; i < mbs.Length; i++) {
            auto mb = mbs.GetMacroblock(i);
            if (mbCache.Exists(tostring(mb.InstId))) {
                @objs = cast<array<Editor::ObjInMap@>>(mbCache[tostring(mb.InstId)]);
                if (objs !is null) {
                    if (objs.Length > 0) {
                        if (UX::SmallButton(Icons::Eye + "##" + mb.InstId)) {
                            Editor::SetCamAnimationGoTo(Editor::DirToLookUvFromCamera(objs[0].pos), objs[0].pos, 120.);
                        }
                        UI::SameLine();
                    }
                    if (UI::TreeNode(tostring(mb.InstId) + ". " + mb.MbName + " ("+objs.Length+")")) {
                        for (uint j = 0; j < objs.Length; j++) {
                            @obj = objs[j];
                            auto item = cast<Editor::ItemInMap>(objs[j]);
                            auto block = cast<Editor::BlockInMap>(objs[j]);
                            if (item !is null) {
                                UI::Text("Item: " + item.IdName);
                            } else if (block !is null) {
                                UI::Text("Block: " + block.IdName);
                            } else {
                                UI::Text("Unknown object");
                            }
                        }
                        UI::TreePop();
                    }
                } else {
                    UI::Text("Objs in cache is null!!");
                }
            } else {
                UI::Text("MB objects not found in cache.");
                UI::SameLine();
                if (UX::SmallButton(Icons::Refresh + "##refresh-cache-mb-" + mb.InstId)) {
                    Editor::GetMapCache().RefreshCacheSoon();
                }
            }
        }
    }
}
