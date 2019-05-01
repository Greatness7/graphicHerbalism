local EasyMCM = include("easyMCM.EasyMCM")

-- Create a placeholder page if EasyMCM is not installed.
if (EasyMCM == nil) or (EasyMCM.version < 1.4) then
    local function placeholderMCM(element)
        element:createLabel{text="This mod config menu requires EasyMCM v1.4 or later."}
        local link = element:createTextSelect{text="Go to EasyMCM Nexus Page"}
        link.color = tes3ui.getPalette("link_color")
        link.widget.idle = tes3ui.getPalette("link_color")
        link.widget.over = tes3ui.getPalette("link_over_color")
        link.widget.pressed = tes3ui.getPalette("link_pressed_color")
        link:register("mouseClick", function()
            os.execute("start https://www.nexusmods.com/morrowind/mods/46427?tab=files")
        end)
    end
    mwse.registerModConfig("Graphic Herbalism", {onCreate=placeholderMCM})
    return
end


-------------------
-- Utility Funcs --
-------------------
local config = require("graphicHerbalism.config")

local function getHerbalismObjects()
    local list = {}
    for obj in tes3.iterateObjects(tes3.objectType.container) do
        if obj.organic then
            list[#list+1] = obj.id:lower()
        end
    end
    table.sort(list)
    return list
end

local function getVolumeAsInteger(self)
    return math.round(config.volume * 100)
end

local function setVolumeAsDecimal(self, value)
    config.volume = math.round(value / 100, 2)
end


----------------------
-- EasyMCM Template --
----------------------
local template = EasyMCM.createTemplate{name="Graphic Herbalism"}
template:saveOnClose("graphicHerbalism", config)
template:register()

-- Preferences Page
local preferences = template:createSideBarPage{label="Preferences"}
preferences.sidebar:createInfo{text="MWSE Graphic Herbalism Version 1.0"}

-- Sidebar Credits
local credits = preferences.sidebar:createCategory{label="Credits:"}
credits:createHyperlink{
    text = "Greatness7",
    exec = "start https://www.nexusmods.com/morrowind/users/64030?tab=user+files",
}
credits:createHyperlink{
    text = "Merlord",
    exec = "start https://www.nexusmods.com/morrowind/users/3040468?tab=user+files",
}
credits:createHyperlink{
    text = "NullCascade",
    exec = "start https://www.nexusmods.com/morrowind/users/26153919?tab=user+files",
}
credits:createHyperlink{
    text = "Petethegoat",
    exec = "start https://www.nexusmods.com/morrowind/users/25319994?tab=user+files",
}
credits:createHyperlink{
    text = "Remiros",
    exec = "start https://www.nexusmods.com/morrowind/users/899234?tab=user+files",
}
credits:createHyperlink{
    text = "Stuporstar",
    exec = "start http://stuporstar.sarahdimento.com/",
}

-- Feature Toggles
local toggles = preferences:createCategory{label="Feature Toggles"}
toggles:createOnOffButton{
    label = "Show ingredient tooltips",
    description = "Show ingredient tooltips\n\nThis option controls whether or not ingredient tooltips will be shown when targeting a valid herbalism container.\n\nDefault: On\n\n",
    variable = EasyMCM:createTableVariable{
        id = "showTooltips",
        table = config,
    },
}
toggles:createOnOffButton{
    label = "Show picked message",
    description = "Show picked messagebox\n\nThis option controls whether or not picked messagebox will be shown after activating a herbalism container.\n\nDefault: On\n\n",
    variable = EasyMCM:createTableVariable{
        id = "showPickedMessage",
        table = config,
    },
}

-- Feature Controls
local controls = preferences:createCategory{label="Feature Controls"}
controls:createSlider{
    label = "Pick Volume: %s%%",
    description = "Pick Volume Description",
    variable = EasyMCM:createVariable{
        get = getVolumeAsInteger,
        set = setVolumeAsDecimal,
    },
}

-- Blacklist Page
template:createExclusionsPage{
    label = "Blacklist",
    description = "All organic containers are treated like flora. Guild chests are blacklisted by default, as are several TR containers. Others can be added manually in this menu.",
    variable = EasyMCM:createTableVariable{
        id = "blacklist",
        table = config,
    },
    filters = {
        {callback = getHerbalismObjects},
    },
}

-- Whitelist Page
template:createExclusionsPage{
    label = "Whitelist",
    description = "Scripted containers are automatically skipped, but can be enabled in this menu. Containers altered by Piratelord's Expanded Sounds are whitelisted by default. Be careful about whitelisting containers using OnActivate, as that can break their scripts.",
    variable = EasyMCM:createTableVariable{
        id = "whitelist",
        table = config,
    },
    filters = {
        {callback = getHerbalismObjects},
    },
}
