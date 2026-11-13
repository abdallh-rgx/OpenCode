local Common_Sound = {
    click = "/Game/WwiseEvent/UI/Play_UI_Click.Play_UI_Click", --所有不知道配什么的按钮都配这个
    confirm = "/Game/WwiseEvent/UI_hall/Play_UI_click2.Play_UI_click2", --“确定”或“需要确定”的按钮，不可同时出现两次
    switch = "/Game/WwiseEvent/UI_hall/Play_UI_click3.Play_UI_click3", --所有页签切换
    object_click = "/Game/WwiseEvent/UI_hall/Play_UI_click4.Play_UI_click4", --所有对象点击，比如物品、邮件、玩家等
    start = "/Game/WwiseEvent/UI/Play_UI_ClickPlay.Play_UI_ClickPlay", --开始游戏性质的按钮
    close = "/Game/WwiseEvent/UI_hall/Play_UI_hall_Close.Play_UI_hall_Close", --所有带X的关闭、取消、后退按钮
    hall_click = "/Game/WwiseEvent/UI_hall/UI_hall_Warehouse.UI_hall_Warehouse", --大厅第一级大类按钮，如枪械库、任务、仓库等
    menu_open = "/Game/WwiseEvent/UI_hall/Play_UI_hall_Pattern_open.Play_UI_hall_Pattern_open", --所有菜单展开动作。但收回则配置Play_UI_hall_Pattern_close
    menu_close = "/Game/WwiseEvent/UI_hall/Play_UI_hall_Pattern_close.Play_UI_hall_Pattern_close", --所有菜单收回动作
}

return Common_Sound