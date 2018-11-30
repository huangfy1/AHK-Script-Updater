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

^k::

;~ FileSelectFile, OutputVar , Options, RootDir\Filename, Prompt, Filter
FileSelectFile, SaveAs, S, ccsetup410.exe
DownloadFileWithProgressBar("http://download.piriform.com/ccsetup410.exe", SaveAs, True, True)
return


^l::
;下载地址
Url=https://raw.githubusercontent.com/Oilj/OnlyTest/master/DoTestScript.ahk
;下载文件名
DownloadAs = AutoHotkey_L cece.ahk
;开启覆盖
Overwrite := True
;开启进度条
UseProgressBar := True

;填入函数开始下载
DownloadFileWithProgressBar(Url,DownloadAs,Overwrite:=true,UseProgressBar:=true)
return

;带有进度条的文件下载
DownloadFileWithProgressBar(UrlToFile,SaveFileAs, Overwrite:=True, UseProgressBar:=True) { ;来自:https://ask.helplib.com/download/post_4702410 感谢
	local
 ;Check if the file already exists and if we must not overwrite it
 ;检查文件是否存在,如果存在并且不允许覆盖,那么任务结束
 If (!Overwrite && FileExist(SaveFileAs))
 Return
 ;Check if the user wants a progressbar
 ;检查是否需要开启进度条
	;如果需要开启则
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
 SetTimer, __UpdateProgressBar, 100 ;每隔100ms更新一次进度
 }
 ;Download the file
 ;下载文件
 UrlDownloadToFile, %UrlToFile%, %SaveFileAs% ;此函数自身即可抛出异常,所以不用管
 ;Remove the timer and the progressbar because the download has finished
 ;任务结束后停止进度条更新计时器
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
 Speed := Round((CurrentSize/1024-LastSize/1024)/((CurrentSizeTick-LastSizeTick)/1000)) . " Kb/s"
 ;Save the current filesize and tick for the next time
 LastSizeTick := CurrentSizeTick
 LastSize := FileOpen(SaveFileAs,"r").Length
 ;Calculate percent done
 PercentDone := Round(CurrentSize/FinalSize*100)
 ;Update the ProgressBar ;进度条更新
 Progress, %PercentDone%, %PercentDone%`% Done, Downloading... (%Speed%), Downloading %SaveFileAs% (%PercentDone%`%)
 Return
}
