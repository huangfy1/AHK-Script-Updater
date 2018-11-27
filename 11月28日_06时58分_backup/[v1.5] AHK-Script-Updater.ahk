#Warn
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

Local_Version:=0.5
DownloadURL:="https://raw.githubusercontent.com/Oilj/AHK-Script-Updater/master/AHK-Script-Updater.ahk"
WikiURL:="https://github.com/Oilj/AHK-Script-Updater/wiki"
Last_VersionURL:="https://raw.githubusercontent.com/Oilj/AHK-Script-Updater/master/Version.ini"

CheckUpdate_Main(Local_Version,Last_VersionURL,DownloadURL,WikiURL)

return ;# 自动执行段结束

;---------------------------------------------------------------------- 

CheckUpdate_Main(Local_Version,Last_VersionURL,DownloadURL,WikiURL){ ;改编自https://github.com/h0ll0w-v0id/AHK_Updater 感谢h0ll0w-v0id 的分享
	
	
whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
whr.Open("GET", Last_VersionURL, true)
whr.Send()
whr.WaitForResponse()
Contents := whr.ResponseText

; 如果下载成功

	If Not ErrorLevel
	{
		Latest_Version := Contents
; 回收内存
		Contents =
	}
	
; 如果有新版本
	If ( Local_Version < Latest_Version )
	{
		iButtonID := TaskDialog(
							+0,  ;参数1
		
							+"软件升级||发现新版本"
		 					. "||本地版本 " Local_Version,    ;参数2
							
							+ "自动下载并更新到 " Latest_Version . "`n点击立即更新" 
							."|手动下载最新版本 " Latest_Version . "`n点击打开网站" 
		  					. "|查看更新信息`n点击打开网站"
							. "|退出`nExit",  ;参数3
							
							+0x10,  ;参数4
							
							+"GREY") ;参数5
							
		If ( iButtonID == 1001 )
		{
			;运行自动更新程序 
		GitHubUpdate(DownloadURL,"",false)
		}							

		If ( iButtonID == 1002 )
		{
			Run, DownloadURL
		}

		Else If ( iButtonID == 1003 )
		{
			Run, WikiURL
		}

		Else If ( iButtonID == 1004 )
		{
			ExitApp
		}
	}
; 如果已经是最新版
	Else If ( Local_Version >= Latest_Version )
	{
		iButtonID := TaskDialog("", "升级||本地软件已是最新版."
							. "`n||本地版本 " Local_Version "`n最新版本 " Latest_Version, "退出 Exit", 0x10, "GREEN")
							
		; custom button 1 - set to close
		If ( iButtonID == 1001 )
		{
			ExitApp
		}	
		
	}
ExitApp

} ;UpdateCheck函数结束

;---------------------------------------------------------------------- 

GitHubUpdate(URL,UpdateTempDir:="",CheckUpdateBeforeStarting:=true,TextCompatMode:=false){
    
global

UpdateStart=%1% ; 命令行参数
SrcPath=%2% ; 命令行参数

; 升级菜单名
_Update:="升级"

; 升级的临时目录
if (UpdateTempDir="")
UpdateTempDir:=A_ProgramFiles "\AHK_Update"

; 新版本程序全路径
UpdateTempFilePath:=UpdateTempDir "\UpdateFile.ahk"

; 绑定函数对象
F_updateMain:=Func("updateMain").Bind(UpdateTempDir)

; 注册升级菜单
Menu,tray,add,%_Update%,% F_updateMain

; 如果发现需要升级,那么就下载文件,并且将源文件替换

if (UpdateStart=="update"){
    
	MsgBox,已接到升级指令`r`n按下确定即从GitHub下载更新文件

	try{
                ;~ MsgBox,% UpdateTempFilePath
                
		TextContainingChieseUpDate(URL,UpdateTempFilePath)

}
catch ex{
	MsgBox,下载失败
}

MsgBox,更新文件已下载完毕

;直接替换
FileMove,% UpdateTempFilePath, % SrcPath ,1

;重启
Run,% SrcPath " UpdateFinish"

ExitApp

}

else if (%1%=="UpdateFinish"){
    Sleep 200
    TrayTip,%A_ScriptName% 升级成功,升级任务已完成
}

}
;---------------------------------------------------------------------- 


; 升级的main函数(目的就是把程序发到另一个地方,并且运行传入参数,开启升级模式)
updateMain(UpdateTempDir){
    
local

; 删除临时目录
	try{
		FileRemoveDir,%UpdateTempDir%,1
}
catch ex{  ;如果发现异常直接无视即可
}

; 建立临时目录
FileCreateDir, %UpdateTempDir%

; 把原脚本复制到临时目录
try{
	FileCopy, %A_ScriptFullPath%, %UpdateTempDir%\OldFile.ahk,1
}
catch ex{ ;如果出错程序就退出
    	MsgBox,16,程序出错,% "复制旧版本程序到临时目录失败" ex.Message
ExitApp
}

; 在临时目录运行旧版本程序,传入命令行参数
Run,%ProgramFilesDir%\Updater.ahk update "%A_ScriptFullPath%"

; 关闭当前程序
ExitApp

return
}


;---------------------------------------------------------------------- 

TextContainingChieseUpDate(URL,newFilePath){ ;目的是从网上下载带有中文ahk文件,如果直接下载的话，即使已经全局设置了UTF-8,中文依然显示不出来
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
;~ MsgBox,% newFilePath
FileAppend,% AHKCode,% newFilePath,UTF-8
}
catch ex{
	MsgBox,16,程序出错,写入错误
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
