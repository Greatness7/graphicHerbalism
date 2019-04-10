local config = require("graphicHerbalism.config")

local function saveConfig()
    mwse.saveConfig("graphicHerbalism", config)
    mwse.log(json.encode(config, {indent=true}))
end

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

local function setSliderLabelAsPercentage(self)
    self.elements.sliderValueLabel.text = (": " .. self.elements.slider.widget.current + self.min .. "%")
end

return {
    name = "Graphic Herbalism",
    pages = {
        {
            label = "Preferences",
            class = "SideBarPage",
            components = {
                {
                    class = "Category",
                    label = "Feature Toggles",
                    components = {
                        {
                            label = "Show ingredient tooltips",
                            class = "OnOffButton",
                            description = "Show ingredient tooltips\n\nThis option controls whether or not ingredient tooltips will be shown when targeting a valid herbalism container.\n\nDefault: On\n\n",
                            variable = {
                                id = "showTooltips",
                                class = "TableVariable",
                                table = config,
                            },
                        },
                    },
                },
                {
                    class = "Category",
                    label = "Volume Controls",
                    components = {
                        {
                            label = "Pick Volume",
                            class = "Slider",
                            description = "Pick Volume Description",
                            variable = {
                                id = "volume",
                                class = "TableVariable",
                                table = config,
                            },
                            postCreate = setSliderLabelAsPercentage,
                            updateValueLabel = setSliderLabelAsPercentage,
                        },
                    },
                },
            },
            sidebarComponents = {
                {
                    class = "MouseOverInfo",
                    text = "MWSE Graphic Herbalism Version 1.0.",
                },
                {
                    class = "Category",
                    label = "Credits:",
                    components = {
                        {
                            class = "Hyperlink",
                            text = "Greatness7",
                            exec = "start https://www.nexusmods.com/morrowind/users/64030?tab=user+files",
                        },
                        {
                            class = "Hyperlink",
                            text = "Merlord",
                            exec = "start https://www.nexusmods.com/morrowind/users/3040468?tab=user+files",
                        },
                        {
                            class = "Hyperlink",
                            text = "NullCascade",
                            exec = "start https://www.nexusmods.com/morrowind/users/26153919?tab=user+files",
                        },
                        {
                            class = "Hyperlink",
                            text = "PeteTheGoat",
                            exec = "start https://www.nexusmods.com/morrowind/users/25319994?tab=user+files",
                        },
                        {
                            class = "Hyperlink",
                            text = "Remiros",
                            exec = "start https://www.nexusmods.com/morrowind/users/899234?tab=user+files",
                        },
                        {
                            class = "Hyperlink",
                            text = "Stuporstar",
                            exec = "start https://stuporstar.sarahdimento.com/",
                        },
                    },
                },
            },
        },
        {
            label = "Blacklist",
            class = "ExclusionsPage",
            description = "All organic containers are treated like flora. Guild chests are blacklisted by default, as are several TR containers. Others can be added manually in this menu.",
            variable = {
                id = "blacklist",
                class = "TableVariable",
                table = config,
            },
            filters = {
                {callback = getHerbalismObjects},
            },
        },
        {
            label = "Whitelist",
            class = "ExclusionsPage",
            description = "Scripted containers are automatically skipped, but can be enabled in this menu. Containers altered by Piratelord's Expanded Sounds are whitelisted by default. Be careful about whitelisting containers using OnActivate, as that can break their scripts.",
            variable = {
                id = "whitelist",
                class = "TableVariable",
                table = config,
            },
            filters = {
                {callback = getHerbalismObjects},
            },
        },
    },
    onClose = saveConfig,
}
