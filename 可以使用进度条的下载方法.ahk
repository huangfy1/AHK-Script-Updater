/*
# AHK标准表头开始
*/
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;~ #Warn ; # 加上错误检查机制,可以很大程度上避免由于AHK的灵活语法导致的逻辑错误
#NoEnv  ; # 不检查空变量是否为"环境变量"，可以极大地提高效率
SetTitleMatchMode 2 ; # 设置标题查找模式
#Hotstring EndChars  ◎ ; # 热字串设置 只是把空格作为终止符,(◎是我找了一个最字符来充数的,主要就是为了实现单独用空格作为热字串终止服符,因为按照帮助文档上所说是不能单独用空格的)
#Hotstring ? O Z ; # 热字串设置 c 区分大小写 o 删除停止符号 Z重置计数器 ?可以混在单词中
#Hotstring NoMouse ; #让鼠标不打扰热字串触发(副作用是 "也阻止了热字串需要的鼠标钩子")
#Warn ClassOverwrite ;#类覆盖警告
#SingleInstance force ; #允许脚本的多个实例运行。 会跳过对话框并自动替换旧实例, 效果类似于 Reload 命令.。
;# 更改脚本的工作目录到"脚本所在目录的绝对路径"
SetWorkingDir %A_ScriptDir%
FileEncoding , UTF-8
SetFormat,Float,0.2 ; # 设置数值转字符串的字符串格式
SendMode Input ;#Input: 让 Send, SendRaw, Click 和 MouseMove/Click/Drag 切换到 SendInput 方法.
;# 同一个热键/热字串最多允许5线程(!!确实需要再开，可能会引起各种问题)
;#MaxThreadsPerHotkey 5
;~ ExitApp ;#
return ;# 自动执行段结束
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
# AHK标准表头结束
*/

^l::
FileSelectFile, SaveAs, S, ccsetup410.exe
DownloadFile("http://download.piriform.com/ccsetup410.exe", SaveAs, True, True)
return



DownloadFile(UrlToFile, SaveFileAs, Overwrite := True, UseProgressBar := True) {
	local
 ;Check if the file already exists and if we must not overwrite it
 If (!Overwrite && FileExist(SaveFileAs))
 Return
 ;Check if the user wants a progressbar
 If (UseProgressBar) {
 ;Initialize the WinHttpRequest Object
 WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
 ;Download the headers
 WebRequest.Open("HEAD", UrlToFile)
 WebRequest.Send()
 ;Store the header which holds the file size in a variable:
 FinalSize := WebRequest.GetResponseHeader("Content-Length")
 ;Create the progressbar and the timer
 Progress, H80,, Downloading..., %UrlToFile%
 SetTimer, __UpdateProgressBar, 100
 }
 ;Download the file
 UrlDownloadToFile, %UrlToFile%, %SaveFileAs%
 ;Remove the timer and the progressbar because the download has finished
 If (UseProgressBar){
 Progress,Off
 SetTimer,__UpdateProgressBar, Off
 }
 Return
 ;The label that updates the progressbar
 __UpdateProgressBar:
 ;Get the current filesize and tick
 CurrentSize := FileOpen(SaveFileAs,"r").Length ;FileGetSize wouldn't return reliable results
 CurrentSizeTick := A_TickCount
 ;Calculate the downloadspeed
 Speed := Round((CurrentSize/1024-LastSize/1024)/((CurrentSizeTick-LastSizeTick)/1000)) . " Kb`/s"
 ;Save the current filesize and tick for the next time
 LastSizeTick := CurrentSizeTick
 LastSize := FileOpen(SaveFileAs,"r").Length
 ;Calculate percent done
 PercentDone := Round(CurrentSize/FinalSize*100)
 ;Update the ProgressBar
 Progress, %PercentDone%, %PercentDone%`% Done, Downloading... (%Speed%), Downloading %SaveFileAs% (%PercentDone%`%)
 Return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; #设置重启当前脚本的热字串 ;rl
#If WinActive(A_ScriptName)
;###保存并重启当前脚本
:?:;rl::
	;# 增加这个主要是为了防止和全局的那个重启冲突,结果以为重启了，其实没有,造成各种问题
	MsgBox ,4,重启%A_ScriptName%,真的要重启"%A_ScriptName%"吗？, 10
	IfMsgBox,Yes
	{
		Sleep 100
		Send ^s
		Sleep 100
		Reload
	}
	else
	{
		TrayTip,重启%A_ScriptName%,"重启%A_ScriptName%"的任务已经取消
	}
return
#If
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;#Include %A_ScriptDir%\lib\Include\声明本地库.ahk
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;