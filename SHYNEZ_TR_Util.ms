--Anime Util
--author: shynez.com
--version 0.1

-- 1. detect if rollout/window/dialog is open
fn Util_IsScriptUIOpen uiName = (
    returnValue = true
    prop = "UISingleton_"+uiName
    MaxINI = getMAXIniFile()
    if not (hasINISetting MaxINI "ThundrayAnime" prop) do (
        returnValue = false
    )
    returnValue
)

fn Util_AddScriptUIOpenState uiName = (
    prop = "UISingleton_"+uiName
    MaxINI = getMAXIniFile()
    setINISetting MaxINI "ThundrayAnime" prop "1"
)

fn Util_DeleteScriptUIOpenState uiName = (
    prop = "UISingleton_"+uiName
    MaxINI = getMAXIniFile()
    delIniSetting MaxINI "ThundrayAnime" prop
)

fn Util_OnlyNumberLeft stringInput = (
	stringOutput = ""
	for i = 1 to stringInput.count do (
		if findString "0123456789" stringInput[i] != undefined do (
			stringOutput += stringInput[i]
		)
	)
	stringOutput
)
