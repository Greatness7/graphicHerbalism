return mwse.loadConfig("graphicHerbalism") or {
    volume = 50,
    showTooltips = true,
    blacklist = {
        -- vanilla content
        ["barrel_01_ahnassi_drink"] = true,
        ["barrel_01_ahnassi_food"] = true,
        ["com_chest_02_mg_supply"] = true,
        ["com_chest_02_fg_supply"] = true,
        -- tamriel rebuilt
        ["t_mwcom_furn_ch2fguild"] = true,
        ["t_mwcom_furn_ch2mguild"] = true,
        ["tr_com_sack_02_i501_mry"] = true,
        ["tr_i3-295-de_p_drinks"] = true,
        ["tr_i3-672_de_rm_deskalc"] = true,
        ["tr_m2_com_sack_i501_bg"] = true,
        ["tr_m2_com_sack_i501_sl"] = true,
        ["tr_m2_com_sack_i501_ww"] = true,
        ["tr_m2_q_27_fgchest"] = true,
        ["tr_m2_q_29_fgchest"] = true,
        ["tr_m3_i395_sack_local1"] = true,
        ["tr_m3_ingchest_i3-390-i"] = true,
        ["tr_m3_oe_anjzhirra_sack"] = true,
        ["tr_m3_soil_i3-390-ind"] = true,
    },
    whitelist = {}
}
