--[[
    Graphic Herbalism v1.0
    By Greatness7
--]]

-- Make sure we have an up-to-date version of MWSE.
if (mwse.buildDate == nil) or (mwse.buildDate < 20190405) then
    event.register("initialized", function()
        tes3.messageBox(
            "[Graphic Herbalism] Your MWSE is out of date!"
            .. " You will need to update to a more recent version to use this mod."
        )
    end)
    return
end


local config = require("graphicHerbalism.config")
local quickloot = include("QuickLoot.interop") or {}
mwse.log("[Graphic Herbalism] Initialized Version 1.0")


-- Register the GUI IDs for our custom tooltips feature.
local GUI_ID = {}
event.register("initialized", function()
    GUI_ID.parent = tes3ui.registerID("GH_Tooltip_Parent")
    GUI_ID.weight = tes3ui.registerID("GH_Tooltip_Weight")
    GUI_ID.value = tes3ui.registerID("GH_Tooltip_Value")
    GUI_ID[1] = tes3ui.registerID("GH_Tooltip_Effect1")
    GUI_ID[2] = tes3ui.registerID("GH_Tooltip_Effect2")
    GUI_ID[3] = tes3ui.registerID("GH_Tooltip_Effect3")
    GUI_ID[4] = tes3ui.registerID("GH_Tooltip_Effect4")
end)


-- Detect if the reference is a valid herbalism subject.
local function isHerb(ref)
    local obj = ref and ref.object
    if obj and obj.organic then
        local id = (obj.baseObject or obj).id:lower()
        if config.blacklist[id] then return false end
        if config.whitelist[id] then return true end
        return (obj.script == nil)
    end
    return false
end


-- Update and serialize the reference's HerbalismSwitch.
local function updateHerbalismSwitch(ref, index)
    local sceneNode = ref.sceneNode
    if not sceneNode then return end

    local switchNode = sceneNode:getObjectByName("HerbalismSwitch")
    if not switchNode then return end

    -- bounds check in case mesh does not implement a spoiled state
    index = math.min(index, #switchNode.children - 1)
    switchNode.switchIndex = index

    -- only serialize if non-zero state (e.g. if picked or spoiled)
    ref.data.GH = (index > 0) and index or nil
end


-- Calls "updateHerbalismSwitch" on appropriate references.
local function updateHerbReferences(cell)
    for ref in cell:iterateReferences(tes3.objectType.container) do
        if isHerb(ref) then
            if not ref.isEmpty then
                updateHerbalismSwitch(ref, 0)
            else -- either picked or spoiled
                updateHerbalismSwitch(ref, math.max(ref.data.GH or 1, 1))
            end
        end
    end
end


-- Calls "updateHerbReferences" when a new cell is loaded.
local currentCells
local function onCellChanged()
    local cells = tes3.getActiveCells()
    local today = tes3.getGlobal("DaysPassed")

    for i, cell in ipairs(cells) do
        local day = currentCells[cell]
        if today > (day or 0) then
            updateHerbReferences(cell)
            cells[cell] = today
        else -- cell is already loaded
            cells[cell] = day
        end
    end

    currentCells = cells
end
event.register("cellChanged", onCellChanged)
event.register("calcRestInterrupt", onCellChanged)
event.register("loaded", function() currentCells = {}; onCellChanged() end)


-- Called when picking a herb, trigger theft if necessary.
local function reportTheft(ref, value)
    local owner = tes3.getOwner(ref)
    if not owner then return end

    local rank = owner.playerJoined and owner.playerRank
    if rank and (rank >= ref.attachments.variables.requirement) then
        return
    end

    tes3.triggerCrime{type=tes3.crimeType.theft, victim=owner, value=value}
end


-- Called when activating a herb, loot all contents and update switch node.
local function onActivate(e)
    local ref = e.target

    -- skip non-ingred
    if not isHerb(ref) then return end

    -- skip pre-picked
    if ref.data.GH then return 0x1 end

    -- resolve contents
    ref:clone()

    -- total gold value
    local value = 1

    -- transfer ingreds
    if #ref.object.inventory == 0 then
        tes3.messageBox("You failed to harvest anything of value.")
        tes3.playSound{reference=ref, sound="Item Ammo Down", volume=config.volume, pitch=0.9}
        updateHerbalismSwitch(ref, 2)
    else
        for i, stack in pairs(ref.object.inventory) do
            if stack.object.canCarry ~= false then
                value = value + (stack.object.value * stack.count)
                tes3.messageBox("You harvested %s %s.", stack.count, stack.object.name)
                tes3.transferItem{from=ref, to=tes3.player, item=stack.object, count=stack.count, playSound=false}
            end
        end
        tes3.playSound{reference=ref, sound="Item Ingredient Up", volume=config.volume, pitch=1.0}
        updateHerbalismSwitch(ref, 1)
    end

    -- detect if stolen
    reportTheft(ref, value)

    -- claim this event
    return false
end
event.register("activate", onActivate, {priority=200})


-- Iterate over an inventory's ingredients, including inside leveled lists.
local function getIngredients(inventory)
    local function ingredsIterator(list)
        for i, node in pairs(list or inventory) do
            if node.object.objectType == tes3.objectType.leveledItem then
                ingredsIterator(node.object.list)
            elseif node.object.objectType == tes3.objectType.ingredient then
                coroutine.yield(node.object)
            end
        end
    end
    return coroutine.wrap(ingredsIterator)
end


-- Get the maximum number of visible effects based on current alchemy skill.
local function getVisibleEffectsCount()
    local skill = tes3.mobilePlayer.alchemy.current
    local gmst = tes3.findGMST(tes3.gmst.fWortChanceValue)
    return math.clamp(math.floor(skill / gmst.value), 0, 4)
end


-- Get the full display name of a magic effect, including attributes/skills.
local function getEffectName(effect, stat)
    local statName
    if effect.targetsAttributes then
        statName = tes3.findGMST(888 + stat).value
    elseif effect.targetsSkills then
        statName = tes3.findGMST(896 + stat).value
    end

    local effectName = tes3.findGMST(1283 + effect.id).value
    if statName then
        return effectName:match("%S+") .. " " .. statName
    else
        return effectName
    end
end


-- Called when targeting a herb, adds ingredient information to the tooltip.
local function onTooltipDrawn(e)
    local ref = e.reference

    -- config override
    if not config.showTooltips then return end

    -- skip non-ingred
    if not isHerb(ref) then return end

    -- block quickloot
    quickloot.skipNextTarget = true

    -- skip pre-picked
    if ref.data.GH then
        e.tooltip.maxWidth = 0
        e.tooltip.maxHeight = 0
        return false
    end

    -- display effects
    local count = getVisibleEffectsCount()
    for ingred in getIngredients(ref.object.inventory) do
        --
        local parent = e.tooltip:createBlock{id=GUI_ID.parent}
        parent.flowDirection = "top_to_bottom"
        parent.childAlignX = 0.5
        parent.autoHeight = true
        parent.autoWidth = true

        local label = parent:createLabel{id=GUI_ID.weight, text=string.format("Weight: %.2f", ingred.weight)}
        label.wrapText = true

        local label = parent:createLabel{id=GUI_ID.value, text=string.format("Value: %d", ingred.value)}
        label.wrapText = true

        for i = 1, 4 do
            local effect = tes3.getMagicEffect(ingred.effects[i])
            local target = math.max(ingred.effectAttributeIds[i], ingred.effectSkillIds[i])

            local block = parent:createBlock{id=GUI_ID[i]}
            block.autoHeight = true
            block.autoWidth = true

            if effect == nil then
                -- pass
            elseif i > count then
                local label = block:createLabel{text="?"}
                label.wrapText = true
            else
                local image = block:createImage{path=("icons\\" .. effect.icon)}
                image.wrapText = false
                image.borderLeft = 4

                local label = block:createLabel{text=getEffectName(effect, target)}
                label.wrapText = false
                label.borderLeft = 4
            end
        end

        break
    end
end
event.register("uiObjectTooltip", onTooltipDrawn, {priority=200})


-- Create a placeholder MCM page if the user doesn't have easyMCM installed.
local function placeholderMCM(element)
    element:createLabel{text="This mod requires the EasyMCM library to be installed."}
    local link = element:createTextSelect{text="Go to EasyMCM Nexus Page"}
    link.color = tes3ui.getPalette("link_color")
    link.widget.idle = tes3ui.getPalette("link_color")
    link.widget.over = tes3ui.getPalette("link_over_color")
    link.widget.pressed = tes3ui.getPalette("link_pressed_color")
    link:register("mouseClick", function()
        os.execute("start https://www.nexusmods.com/morrowind/mods/46427?tab=files")
    end)
end


local function registerModConfig()
    local easyMCM = include("easyMCM.modConfig")
    local mcmData = require("graphicHerbalism.mcm")
    local modData = easyMCM and easyMCM.registerModData(mcmData)
    mwse.registerModConfig(mcmData.name, modData or {onCreate=placeholderMCM})
end
event.register("modConfigReady", registerModConfig)


-- Autodetect blacklist candidates. Not perfect, but is better than nothing.
local function updateBlacklist()
    for obj in tes3.iterateObjects(tes3.objectType.container) do
        local id = obj.id:lower()
        if (obj.organic
            and obj.script == nil
            and #obj.inventory > 0
            and config.blacklist[id] == nil
            and config.whitelist[id] == nil
            )
        then
            if (id:find("barrel")
                or id:find("chest")
                or id:find("crate")
                or id:find("sack")
                or getIngredients(obj.inventory)() == nil)
            then
                mwse.log('[Graphic Herbalism] Invalid container "%s" added to blacklist.', id)
                config.blacklist[id] = true
            end
        end
    end
end
event.register("initialized", updateBlacklist)
