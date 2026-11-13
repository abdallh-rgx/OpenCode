PersonSpaceAppearance = PersonSpaceAppearance or
        {

        }

function bp_person_space_appearance_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_person_space_appearance,
            {{Path = "/Game/UMG/UI_Logic/PersonSpace/PersonSpaceAppearance_BP.PersonSpaceAppearance_BP_C", Container = "Default", ZOrder = BP_ENUM_UI_ROLEINFO_ZORDER + 10}},
            {"Lobby"},
            false,
            false,
            true
    );
end


function PersonSpaceAppearance.ShowUI()
    LuaClassObj.HandleDynamicCreation(bp_person_space_appearance);
    LuaClassObj.HandleUIMessage(bp_person_space_appearance, "UIShow");
end

function PersonSpaceAppearance.HideUI()
    LuaClassObj.HandleUIMessage(bp_person_space_appearance, "UIHide");
end
