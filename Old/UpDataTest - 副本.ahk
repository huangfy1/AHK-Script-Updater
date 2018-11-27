;~ #Warn
#NoEnv
SetTitleMatchMode 2
#Hotstring EndChars  ◎
#Hotstring ? O Z ; # 热字串设置 c 区分大小写 o 删除停止符号 Z重置计数器 ?可以混在单词中
#Hotstring NoMouse ; #让鼠标不打扰热字串触发(副作用是 "也阻止了热字串需要的鼠标钩子")
#Warn ClassOverwrite ;#类覆盖警告
#SingleInstance force ; #允许脚本的多个实例运行。 会跳过对话框并自动替换旧实例, 效果类似于 Reload 命令.。
;# 更改脚本的工作目录到"脚本所在目录的绝对路径"
SetWorkingDir %A_ScriptDir%
FileEncoding , UTF-8
SetFormat,Float,0.2 ; # 设置数值转字符串的字符串格式
SendMode Input ;#Input: 让 Send, SendRaw, Click 和 MouseMove/Click/Drag 切换到 SendInput 方法.

UpdateStart=%1% ; 命令行参数不能使用直接使用表达式形式调用
SrcPath=%2% ; 命令行参数不能使用直接使用表达式形式调用

;----------------------------------------------------------------------
; 升级菜单名
_Update:="升级"

; 升级的临时目录
UpdateTempDir:=A_ProgramFiles "\AHK_Update"
UpdateTempFileDir:=UpdateTempDir "\file.ahk"

; 绑定函数对象
F_updateMain:=Func("updateMain").Bind(UpdateTempFileDir)

; 注册升级菜单
Menu,tray,add,%_Update%,% F_updateMain

; 如果发现需要升级,那么就下载文件,并且将源文件替换

if (UpdateStart=="update"){
	MsgBox,已接到升级指令`r`n按下确定即从GitHub下载更新文件
	URL:="https://raw.githubusercontent.com/szzhiyang/PerfectWindows/master/Power-Keys/Power-Keys.ahk"
	try{
                MsgBox,% UpdateTempFileDir
		TextContainingChieseUpDate(URL,UpdateTempFileDir)

}
catch ex{
	MsgBox,下载失败
}

MsgBox,更新文件已下载完毕

;直接替换
FileMove,% UpdateTempFileDir, % SrcPath ,1

;重启
Run,% SrcPath " UpdateFinish"

ExitApp

}

else if (%1%=="UpdateFinish"){
    Sleep 200
    TrayTip,%A_ScriptName% 提醒,升级任务已完成
}


return ;# 自动执行段结束



; 升级的main函数
updateMain(UpdateTempDir:="C:\"){
local

; 删除临时目录
	try{
		FileRemoveDir,%UpdateTempDir%,1
}
catch ex{  ;如果发现异常直接无视即可
}

; 建立临时目录
FileCreateDir, %UpdateTempDir%
try{
	FileCopy, %A_ScriptFullPath%, %ProgramFilesDir%\Updater.ahk,1
}
catch ex{ ;如果出错程序就退出
	MsgBox,% "程序出错" ex.Message
ExitApp
}

; 运行临时程序并传入参数,然后这个程序就可以关闭了
    ;第一个参数是update字符串,用于识别是否开始升级 第二个参数是源程序的地址,便于下载完之后进行替换
Run,%ProgramFilesDir%\Updater.ahk update "%A_ScriptFullPath%"

; 关闭当前程序
ExitApp

return
}

;--------------------------
TextContainingChieseUpDate(URL,newFilePath){
	local
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET",URL, true)
	whr.Send()
	whr.WaitForResponse()
	AHKCode:= whr.ResponseText
	try{
		FileRemoveDir,%newFilePath%,1
}
catch ex{  ;如果发现异常直接无视即可
}
try{
	;~ MsgBox,% AHKCode
MsgBox,% newFilePath
FileAppend,% AHKCode,% newFilePath,UTF-8
}
catch ex{
	MsgBox,文件写入失败
}
return
}


^l::

return


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
