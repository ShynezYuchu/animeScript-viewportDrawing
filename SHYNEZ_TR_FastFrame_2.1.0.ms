--Anime Fast Frame
--author: shynez.com
--version 2.1
fileIn "SHYNEZ_TR_Util.ms"


if Util_IsScriptUIOpen "SHYNEZ_TR_FastFrame" do (
      return print "The script instance is already open."
)
Util_AddScriptUIOpenState "SHYNEZ_TR_FastFrame"


isFirstTimeRun

frameArr
trffLeft;trffRight;trffTop;trffBottom
clickPoints
previousVptSize;currentVptSize
previousVptSFSize;currentVptSFSize
resizeRatio
showInVptState
activeFrameIndex
UICtrlArr
isCameraViewOnly
-- start def perspective guidelines
perspGuideList
perspGuidePoints

perspGuidePointColors
PG_REDRAW_flag
vptpInit
drawPalette
vptPoint
rectWidth
rectHeight
rectMargin
rectArray
gwColor
-- end of def perspective guidelines

isPGFreedrawON = false

fn InitVars =
(
	frameArr = #()
	trffLeft = #(0,0,0);trffRight = #(0,0,0);trffTop = #(0,0,0);trffBottom = #(0,0,0)
	clickPoints = #()
	previousVptSize = undefined;currentVptSize = undefined
	previousVptSFSize = undefined;currentVptSFSize = undefined
	resizeRatio = 1
	showInVptState = true
	activeFrameIndex = 1
	UICtrlArr = #()
	isCameraViewOnly = true
	-- start init perspective guidelines
	perspGuideList = #()
	perspGuidePoints = #()
	
	perspGuidePointColors = #()
	PG_REDRAW_flag = false
	vptpInit = false
	drawPalette = false
	vptPoint = [300, 300]
	rectWidth = 70
	rectHeight = 60
	rectMargin = 5
	rectArray = #()
	gwColor = red
	 -- end of init perspective guidelines
)

if isFirstTimeRun == undefined do
(
	isFirstTimeRun = "MyGo"
	InitVars()
)

fn GetViewportSafeFrameSize =
(
    local viewAspect = (getViewSize())[1] as float / (getViewSize())[2]
    local renderAspect = renderWidth as float / renderHeight

    local x, y, w, h
    if (viewAspect > renderAspect) then
    (       
        h = (getViewSize())[2]
        w = (h * renderAspect) as integer
        y = 0
        x = ((getViewSize())[1] - w) / 2
    )
    else
    (
        w = (getViewSize())[1]
        h = (w / renderAspect) as integer
        x = 0
        y = ((getViewSize())[2] - h) / 2        
    )
    return box2 x y w h
)
currentVptSFSize = GetViewportSafeFrameSize()
callbacks.removeScripts id:#ReadFrameArrOnFileOpen
callbacks.removeScripts id:#SaveFrameArrOnFileSave

fn ResizeUpdate =
(
	if currentVptSize == undefined do currentVptSize = getViewSize()
	if currentVptSFSize == undefined do currentVptSFSize = GetViewportSafeFrameSize()
	
	if (GetViewportSafeFrameSize()).w != currentVptSFSize.w or getViewSize() != currentVptSize do
	(
		previousVptSize = currentVptSize
		previousVptSFSize = currentVptSFSize
		resizeRatio = (GetViewportSafeFrameSize()).w as float / previousVptSFSize.w
		currentVptSize = getViewSize()
		currentVptSFSize = GetViewportSafeFrameSize()
			
		for i = 1 to frameArr.count where frameArr[i] != undefined do
		(
			local frame = #()
			for p = 1 to 4 do
			(
				local x = (((frameArr[i])[p])[1]-previousVptSFSize.x)*resizeRatio+currentVptSFSize.x
				local y = (((frameArr[i])[p])[2]-previousVptSFSize.y)*resizeRatio+currentVptSFSize.y
				append frame [x,y,0]
			)
			frameArr[i] = frame
		)
		
        -- start resize perspective guidelines
		if perspGuideList != undefined do
		(
			for points = 1 to perspGuideList.count do
			(
				for p = 1 to perspGuideList[points].count do
				(
					perspGuideList[points][p] *= resizeRatio
				)
			)
			for p = 1 to perspGuidePoints.count do
			(
				perspGuidePoints[p] *= resizeRatio
			)
		)
        -- end of resize perspective guidelines
	)
)

fn FfRecalc = 
(
	frameArr[activeFrameIndex] = #([trffLeft[activeFrameIndex],trffTop[activeFrameIndex],0],[trffLeft[activeFrameIndex],trffBottom[activeFrameIndex],0],[trffRight[activeFrameIndex],trffBottom[activeFrameIndex],0],[trffRight[activeFrameIndex],trffTop[activeFrameIndex],0])
)

fn DrawCircle =
(
	for pos in clickPoints do
		gw.wMarker pos ("circle" as name) color:green
)

fn DrawFrame = 
(
	for i = 1 to 3 do
		if frameArr != undefined and frameArr[i] != undefined do
		(
			gw.setColor #line (if i==1 then red else if i==2 then green else blue)
			gw.wPolyline frameArr[i] true
		)
)

-- start fn perspective guidelines
fn DrawGuideline =
(
    gw.setColor #text red
    if isPGFreedrawON do
        gw.hText [100,20,0] "Tips: CTRL + LeftButton = Undo, SHIFT + MoveToArea = Palette"
	for i = 1 to perspGuideList.count do
	(
		gw.setColor #line perspGuidePointColors[i]
		gw.wPolyline perspGuideList[i] false
	)

	if perspGuidePoints.count > 0 do
	(
		gw.setColor #line gwColor
		gw.wPolyline perspGuidePoints false
	)

)-- end of fn perspective guidelines

fn DrawPaletteFunc =
(
	if drawPalette do
	(
	rectR = box2 (vptPoint[1]-rectMargin-rectWidth) (vptPoint[2]-rectMargin*2-rectHeight*1.5) (rectWidth) rectHeight
	rectG = box2 (vptPoint[1]-rectMargin-rectWidth*1.3) (vptPoint[2]-rectHeight/2) rectWidth rectHeight
	rectB = box2 (vptPoint[1]-rectMargin-rectWidth) (vptPoint[2]+rectMargin*2+rectHeight/2) rectWidth rectHeight
	rectY = box2 (vptPoint[1]+rectMargin) (vptPoint[2]-rectMargin*2-rectHeight*1.5) rectWidth rectHeight
	rectW = box2 (vptPoint[1]+rectMargin+rectWidth*0.3) (vptPoint[2]-rectHeight/2) rectWidth rectHeight
	rectBlack = box2 (vptPoint[1]+rectMargin) (vptPoint[2]+rectMargin*2+rectHeight/2) rectWidth rectHeight
	
	rectArray = #(rectR, rectG, rectB, rectY, rectW, rectBlack)
		
	gw.wrect rectR (color 136 8 8)
	gw.wrect rectG (color 8 136 8)
	gw.wrect rectB (color 8 8 136)
	gw.wrect rectY (color 135 110 8)
	gw.wrect rectW (color 200 200 200)
	gw.wrect rectBlack black
	
	gw.wPolyline #([rectR.x-rectMargin, rectR.y-rectMargin*2, 0],\
		[rectG.x-rectMargin*6, vptPoint[2], 0],\
		[rectB.x-rectMargin, rectB.y+rectHeight+rectMargin*2, 0],\
		[rectBlack.x+rectWidth+rectMargin, rectBlack.y+rectHeight+rectMargin*2, 0],\
		[rectW.x+rectWidth+rectMargin*6, vptPoint[2]+rectMargin*2, 0],\
		[rectY.x+rectWidth+rectMargin, rectY.y-rectMargin*2, 0]) true \
		rgb:#((color 136 8 8),(color 8 136 8),(color 8 8 136),black,(color 200 200 200),(color 135 110 8))
	)
)


if FfRedraw != undefined do unregisterRedrawViewsCallback FfRedraw
fn FfRedraw =
(
	gw.setTransform(matrix3 1)
	ResizeUpdate()
	local visibility = true
	if showInVptState do
	(
		if not (isCameraViewOnly and viewport.getType() != #view_camera) do
		(
			DrawFrame()
            DrawCircle()
			DrawGuideline()
			DrawPaletteFunc()
		)
	)	
	gw.enlargeUpdateRect #whole
	gw.updateScreen()
)
registerRedrawViewsCallback FfRedraw

fn EnableRollout bool UICtrlArr =
(
	for ctrl in UICtrlArr do
		ctrl.enabled = bool
)

fn Set16_9Points = 
(
    trffLeft[activeFrameIndex] = amin clickPoints[1].x clickPoints[2].x
    trffRight[activeFrameIndex] = amax clickPoints[1].x clickPoints[2].x
    trffTop[activeFrameIndex] = amin clickPoints[1].y clickPoints[2].y
    trffBottom[activeFrameIndex] = amax clickPoints[1].y clickPoints[2].y
    FfRecalc()
)

tool ModifyRedraw
(
	on mousePoint click do 
	(
        append clickPoints [viewPoint[1],viewPoint[2],0]
        completeRedraw()
        
        if clickPoints.count >= 3 do stopTool ModifyRedraw
    )
    on mouseMove click do
    (
        if clickPoints[1] != undefined do
        (
            clickPoints[2] = [viewPoint[1],viewPoint[2],0]
            
            Set16_9Points()
        )
        completeRedraw()
    )
    on mouseAbort click do
    (
        clickPoints = #()
    )
	on stop do 
	(
		clickPoints = #()
		EnableRollout true UICtrlArr
	)
)

fn ColorChoosed pointShiftReleased =
(
	if pointShiftReleased[1] > rectArray[1].x and pointShiftReleased[1] < rectArray[1].x + rectWidth \
		and pointShiftReleased[2] > rectArray[1].y and pointShiftReleased[2] < rectArray[1].y + rectHeight 
		then 1
	else if pointShiftReleased[1] > rectArray[2].x and pointShiftReleased[1] < rectArray[2].x + rectWidth \
		and pointShiftReleased[2] > rectArray[2].y and pointShiftReleased[2] < rectArray[2].y + rectHeight 
		then 2
	else if pointShiftReleased[1] > rectArray[3].x and pointShiftReleased[1] < rectArray[3].x + rectWidth \
		and pointShiftReleased[2] > rectArray[3].y and pointShiftReleased[2] < rectArray[3].y + rectHeight 
		then 3
	else if pointShiftReleased[1] > rectArray[4].x and pointShiftReleased[1] < rectArray[4].x + rectWidth \
		and pointShiftReleased[2] > rectArray[4].y and pointShiftReleased[2] < rectArray[4].y + rectHeight 
		then 4
	else if pointShiftReleased[1] > rectArray[5].x and pointShiftReleased[1] < rectArray[5].x + rectWidth \
		and pointShiftReleased[2] > rectArray[5].y and pointShiftReleased[2] < rectArray[5].y + rectHeight 
		then 5
	else if pointShiftReleased[1] > rectArray[6].x and pointShiftReleased[1] < rectArray[6].x + rectWidth \
		and pointShiftReleased[2] > rectArray[6].y and pointShiftReleased[2] < rectArray[6].y + rectHeight 
		then 6
	else undefined
)

fn ToolShiftKeyFunc viewPoint shiftKey ctrlKey = 
(
if shiftKey and not ctrlKey then
	(
	if not vptpInit do
	(
		vptPoint = viewPoint
		vptpInit = true
	)
	) else
	(
	if vptpInit and (ColorChoosed viewPoint) != undefined and not shiftKey and not ctrlKey do
	(
		case (ColorChoosed viewPoint) of
		(
		1: gwColor = red
		2: gwColor = green
		3: gwColor = blue
		4: gwColor = yellow
		5: gwColor = white
		6: gwColor = black
		)
	)
	vptpInit = false
	)
	drawPalette = shiftKey and not ctrlKey
)

-- start tool perspective guidelines
tool ModifyPGRedraw
(
	on mousePoint click do 
	(
		if click == 1 then
		(
			perspGuidePoints[1] = [viewPoint[1],viewPoint[2],0]
		) else if click > 1 then
		(
			if ctrlKey then
			(
				if click > 2 and perspGuideList.count > 0 do
				(
					deleteItem perspGuideList perspGuideList.count
					deleteItem perspGuidePointColors perspGuidePointColors.count

					completeRedraw()
				)
			) else
			(
				append perspGuideList perspGuidePoints
				append perspGuidePointColors gwColor
				perspGuidePoints = #()
	
				completeRedraw()
				PG_REDRAW_flag = false
			)
		)
	)
	on freeMove do
	(
		ToolShiftKeyFunc viewPoint shiftKey ctrlKey
		completeRedraw()
	)
	on mouseMove click do
	(
		ToolShiftKeyFunc viewPoint shiftKey ctrlKey
		
		if not ctrlKey then
		(
			if click > 1 and not PG_REDRAW_flag and lButton then
			(
				PG_REDRAW_flag = true
				perspGuidePoints[1] = [viewPoint[1],viewPoint[2],0]
			)
	
			if perspGuidePoints[1] != undefined do
				perspGuidePoints[2] = [viewPoint[1],viewPoint[2],0]
		)	
		completeRedraw()
	)
	on mouseAbort click do
	(
		perspGuidePoints = #()
		PG_REDRAW_flag = false
	)
	on stop do 
	(
		perspGuidePoints = #()

        isPGFreedrawON = false
		EnableRollout true UICtrlArr
	)
)

tool ModifyPGFreedraw
(
	on mousePoint click do 
	(
		if click == 1 then
		(
			append perspGuidePoints [viewPoint[1],viewPoint[2],0]
		) else if click > 1 then
		(
			if ctrlKey then
			(
				if click > 2 and perspGuideList.count > 0 do
				(
					deleteItem perspGuideList perspGuideList.count
					deleteItem perspGuidePointColors perspGuidePointColors.count

					completeRedraw()
				)
			) else
			(
				append perspGuideList perspGuidePoints
				append perspGuidePointColors gwColor
				perspGuidePoints = #()

				completeRedraw()
				PG_REDRAW_flag = false
			)
		)
	)
	on freeMove do
	(
		ToolShiftKeyFunc viewPoint shiftKey ctrlKey
		completeRedraw()
	)
	on mouseMove click do
	(
		ToolShiftKeyFunc viewPoint shiftKey ctrlKey
		
		if not ctrlKey then
		(
			if click > 1 and not PG_REDRAW_flag and lButton then
			(
				PG_REDRAW_flag = true
				perspGuidePoints[1] = [viewPoint[1],viewPoint[2],0]
			)
	
			if perspGuidePoints[1] != undefined do
			(
				append perspGuidePoints [viewPoint[1],viewPoint[2],0]
			)
		)

		completeRedraw()
	)
	on mouseAbort click do
	(
		perspGuidePoints = #()
	)
	on stop do
	(
		perspGuidePoints = #()
        EnableRollout true UICtrlArr
        
        isPGFreedrawON = false
	)
)
-- end of tool perspective guidelines

fn ReadFrameArrOnFileOpen =
(
	filePropFrame = fileProperties.findProperty #custom "com_shynez_FastFrame_frameArr"
	if filePropFrame > 0 do
	(
		tmpFrameArr = execute(fileProperties.getPropertyValue #custom (fileProperties.findProperty #custom "com_shynez_FastFrame_frameArr"))
		if tmpFrameArr != undefined do
			frameArr = tmpFrameArr
	)
	filePropVptSize = fileProperties.findProperty #custom "com_shynez_FastFrame_viewportSizeArr"
	if filePropVptSize > 0 do
	(
		tmpFrameArr = execute(fileProperties.getPropertyValue #custom (fileProperties.findProperty #custom "com_shynez_FastFrame_viewportSizeArr"))
		if tmpFrameArr != undefined and tmpFrameArr.count > 0 do
		(
			previousVptSize = tmpFrameArr[1]
			currentVptSize = tmpFrameArr[2]
			previousVptSFSize = tmpFrameArr[3]
			currentVptSFSize = tmpFrameArr[4]
			
			ResizeUpdate()
		)
		
	)
)
callbacks.addScript #filePostOpen "ReadFrameArrOnFileOpen()" id:#ReadFrameArrOnFileOpen

fn SaveFrameArrOnFileSave =
(
	if frameArr.count > 0 do
	(
		fileProperties.addProperty #custom "com_shynez_FastFrame_frameArr" (frameArr as string)
		viewportSizeArr = #()
		append viewportSizeArr previousVptSize
		append viewportSizeArr currentVptSize
		append viewportSizeArr previousVptSFSize
		append viewportSizeArr currentVptSFSize
		fileProperties.addProperty #custom "com_shynez_FastFrame_viewportSizeArr" (viewportSizeArr as string)
	)
)
callbacks.addScript #filePreSave "SaveFrameArrOnFileSave()" id:#SaveFrameArrOnFileSave

rollout SHYNEZ_TR_My_FastLayout "Fast Frame 2.0.0"
(	
	checkbutton showBG "BG" across:4 offset:[-7,5] highlightColor:[135,6,6] toolTip:"显示背景"
	checkbutton showFL "V"  offset:[-22,5] highlightColor:[6,135,6] toolTip:"显示框绘"
	checkbutton cameraViewOnly "C" offset:[-41,5] highlightColor:[6,6,135] toolTip:"仅摄像机视图可见"
	button openBgImage ">> 加载背景 <<" offset:[-22,5]
	group "框框"
	(
		radiobuttons activeFrame labels:#("[A]","[B]","[C]") offsets:#([-20,0],[0,0],[20,0])
		button ctrlEnable "重绘" width:80 across:2
		button clearFrame "清除" width:80
	)
	-- start ui perspective guidelines
	group "辅助线"
	(
		label guidelines "绘制辅助线" across:2 offset:[0,5]
		button clearPG "清除" offset:[20,0]
		button lineDraw "直线绘制" width:80 across:2
		button freeDraw "自由绘制" width:80
	)
	Label author "Author" align:#left across:2
	hyperLink authorLink "shynez语出" color:red hoverColor:red visitedColor:green address:"http://shynez.com/" align:#right
    -- end of ui perspective guidelines
	
	on openBgImage pressed do
	(
		renderSceneDialog.close()

		global f = getOpenFileName caption:"Select an image"
		if f != undefined do
		(
			bgBitmap = openBitMap f
			setAsBackground bgBitmap
			renderWidth = bgBitmap.width
			renderHeight = bgBitmap.height
			setBkgImageAspect #output
			displaySafeFrames = true
			showBG.checked = true
			actionMan.executeAction 0 "620"
		)
	)
	
	on showBG changed value do
	(
		if showBG.checked then
			actionMan.executeAction 0 "620"
		else 
			actionMan.executeAction 0 "617"
	)
	
	on showFL changed value do
	(
		if showFL.checked then 
		(
			showInVptState = true
 			EnableRollout true #(cameraViewOnly,ctrlEnable,activeFrame,clearFrame,lineDraw,freeDraw,clearPG)
		) else 
		(
			showInVptState = false
			stopTool ModifyRedraw
			EnableRollout false #(cameraViewOnly,ctrlEnable,activeFrame,clearFrame,lineDraw,freeDraw,clearPG)
		)
	)
	on cameraViewOnly changed value do
	(
		isCameraViewOnly = cameraViewOnly.checked
	)
	
	on ctrlEnable pressed do 
	(
		EnableRollout false UICtrlArr
		startTool ModifyRedraw
	)
 	on activeFrame changed i do
	(
		activeFrameIndex = i
	)
	on clearFrame pressed do
        frameArr[activeFrameIndex] = undefined
        
    -- start event perspective guidelines
    on lineDraw pressed do
	(
        EnableRollout false UICtrlArr
        isPGFreedrawON = true
		startTool ModifyPGRedraw
	)
	on freeDraw pressed do
	(
        EnableRollout false UICtrlArr
        isPGFreedrawON = true
		startTool ModifyPGFreedraw
	)
	on clearPG pressed do
	(
		perspGuideList = #()
		perspGuidePointColors = #()
		perspGuidePoints = #()
	)
    -- end of event perspective guidelines
	on SHYNEZ_TR_My_FastLayout open do
	(
		if frameArr.count == 0 do ReadFrameArrOnFileOpen()
		showFL.checked = if showInVptState then true else false
		cameraViewOnly.checked = if isCameraViewOnly then true else false
		
		if showFL.checked then 
		(
 			EnableRollout true #(cameraViewOnly,ctrlEnable,activeFrame,clearFrame,lineDraw,freeDraw,clearPG)
		) else 
		(
			stopTool ModifyRedraw
			EnableRollout false #(cameraViewOnly,ctrlEnable,activeFrame,clearFrame,lineDraw,freeDraw,clearPG)
		)
		UICtrlArr = #(openBgImage,showBG,showFL,ctrlEnable,activeFrame,clearFrame,lineDraw,freeDraw,clearPG)
	)
	on SHYNEZ_TR_My_FastLayout close do
	(
        stopTool ModifyRedraw
        stopTool ModifyPGRedraw

        Util_DeleteScriptUIOpenState "SHYNEZ_TR_FastFrame"
	)
)

createDialog SHYNEZ_TR_My_FastLayout width:200 height:190 pos:[300,285] style:#(#style_titlebar, #style_border, #style_sysmenu)

cui.RegisterDialogBar SHYNEZ_TR_My_FastLayout