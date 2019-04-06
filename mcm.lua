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
					text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
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
			description = "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.",
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
            description = "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.",
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
