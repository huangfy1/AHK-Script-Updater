#NoEnv
SetTitleMatchMode 2
#Hotstring EndChars  ◎
#Hotstring NoMouse
#SingleInstance force 
SetWorkingDir %A_ScriptDir%
FileEncoding , UTF-8

#Include %A_ScriptDir%\TaskDialog.ahk ;导入用户更新选择器(GUI)
#Include %A_ScriptDir%\lib\DownloadFileWithProgressBar.ahk ;导入下载器(GUI)
#Include %A_ScriptDir%\ce.ahk ;导入下载器(GUI)

/*[后期作为命令行传入方法] 
;--------------------------------------------------------------------- 
;参数接收区域

	;必填参数

		;启动字符串(必填)
		FristParaMeter=%1%
			;接收到"Update"启动更新程序(不区分大小写),参数未传入,或接收到其他任何字符串,程序立即终止退出
			if !(FristParaMeter="Update")
				ExitApp
		;请求者自身路径(必填)
		SoftPath=%2%
			;收到参数之后会先检查格式
			if !(RegExMatch(SoftPath,"^[a-zA-Z]:(//[^///:""<>/|]+)+$"))
				ExitApp
	
			;自动生成请求软件的根目录
			SoftDir
	
		;更新文件下载地址(必填)
		DownLoadURL=%3%
	
	
	;非必填参数
	
		;版本文件下载地址(默认是同GitHub目录下的Version.txt文件)
		Last_VersionURL=%4%
		
	;当前版本(如果输入纯数字,版本就是参数,如果并非纯数字,那么认为是和SoftPath同路径的版本文件的文件名)(默认参数是"Version.txt")
	Local_Version=%5%
	
	;更新临时文件地址(默认是原软件根目录下的%SoftDir%\CacheFile文件)
	TempFilePath=%6%
	
;---------------------------------------------------------------------- 
*/

;参数接收区域

	;必填参数

		;启动字符串(必填)√
		FristParaMeter:="Update"
			;接收到"Update"启动更新程序(不区分大小写),参数未传入,或接收到其他任何字符串,程序立即终止退出
			if (FristParaMeter!="Update"){
TrayTip,%A_ScriptName% 提醒,启动字符串错误，程序已退出
			ExitApp
			}

		;请求者自身路径(必填) √
		SoftPath:="D:\GitHub\OnlyTest\DoTestScript.ahk"
			;本来想用正则检查的,现在感觉其实没必要,在真正用的时候通过try来捕捉错误就行了(毕竟AHK会替我们检查)
	
			;自动生成请求软件的根目录 √
			SoftDir:="null"
			FoundPos_0 := InStr(SoftPath, "/" ,false,0,1)
			FoundPos_1 := InStr(SoftPath, "\" ,false,0,1)
				;找到最后一个斜杠的位置
			FoundPos:=(FoundPos_0>=FoundPos_1)?FoundPos_0:FoundPos_1
				;提取出调用者本身的名字(前面带着斜杠),并且对可能存在的反斜杠转义
			SoftName:=StrReplace(SubStr(SoftPath,FoundPos),"\","\\")
				;使用正则替换掉调用者本身(使用正则仅仅替换掉最后一个被匹配的)
			SoftDir:=RegExReplace(SoftPath,"(" SoftName ")$" )
				;去除正反斜杠得到真正的SoftName
			SoftName:=StrReplace((SoftName:=StrReplace(SoftName,"\","")),"/","")
			
			
	
		;更新文件下载地址(必填)√
		DownLoadURL:="https://raw.githubusercontent.com/Oilj/OnlyTest/master/DoTestScript.ahk"
	
	
	;非必填参数
	
		;版本文件下载地址(默认是同GitHub目录下的Version.txt文件)
		Last_VersionURL:="https://raw.githubusercontent.com/Oilj/OnlyTest/master/Version.txt"
		
	;当前版本
	Local_Version:=0.5
	;Trim掉各种空白符
	Local_Version:=Trim(Local_Version," `t`r`n`f`a`v`b")
	;使用正则检查"Local_Version"是否是纯数字(可以含‘.’)
	FoundPos := RegExMatch(Local_Version,"([0-9]|\.)+" ,OutputVar,StartingPosition := 1)
	
		;如果输入纯数字,版本就是参数,如果并非纯数字,那么则认为是路径名
		if (OutputVar!=Local_Version){
		Local_VersionPath:=Local_Version
		;读取版本文件到变量
		FileRead, Local_Version, %Local_VersionPath%	
}


	;更新临时文件地址(默认是原软件根目录下的%SoftDir%\CacheFile文件)
	TempFilePath=%SoftDir%\CacheFile
	
	;更新说明地址
	WikiURL:="https://github.com/Oilj/OnlyTest/wiki"
println(Local_Version),println(Last_VersionURL),println(DownloadURL),println(WikiURL)

	;运行更新程序(该函数内变量为Globol模式)
Main_Updater(DownLoadURL,SoftPath,"",EnableCheckUpdate:=true,EnableBackup:=true,RunAfterUpdate:=true,UpdateVersionFile:=true)

return ;# 自动执行段结束
;---------------------------------------------------------------------- 

Main_Updater(DownLoadURL,SoftPath,TempFilePath:="",EnableCheckUpdate:=true,EnableBackup:=true,RunAfterUpdate:=true,UpdateVersionFile:=false){

;假定全局变量模式
global

;如果没有输入临时路径的话，那么就在更新器根目录下使用"Update.temp"作为文件名
if(TempFilePath="")
	TempFilePath:="Update.temp"

;建立函数对象
D_Update:=Func("DownloadFileWithProgressBar").bind(DownLoadURL,TempFilePath,true,true,"更新中...")
;~ DownloadFileWithProgressBar(UrlToFile, TempFilePath, Overwrite := True, UseProgressBar := True, ProgressBarTitle:="更新中...")

;检查是否"检查更新"
if(EnableCheckUpdate){
	;如果检查更新的话，那么就调用CheckUpdate方法,最后让用户根据自己的情况选择更新方法
	CheckUpdate(Local_Version,Last_VersionURL,DownloadURL,D_Update,WikiURL)
}
	;如果不检查更新的话，那么就直接下载即可
else 
%D_Update%()

;备份旧文件
if (EnableBackup){
thedate:=ReturnDate(Format:="nyrufm")
backuppath=%A_WorkingDir%\backup\%SoftName%_%thedate%.old
	Filecopy,%SoftPath%,%backuppath%
}

;用新的文件覆盖旧文件
 FileCopy,%TempFilePath%,%SoftPath%,%true%
;删除临时文件
 FileDelete,%TempFilePath%
 
 ;更新版本号文件(如果用户需要)
 if (UpdateVersionFile!=false){
VersionPath=%SoftDir%\Version.txt
 FileDelete,%VersionPath%
 FileAppend,%Latest_Version%,%VersionPath%
 }
	
;运行新文件
if (RunAfterUpdate){

	;运行，并且传入命令行参数
		;参数1:通知用户已完成更新
			UpdateFinished:="UpdateFinished"
		;参数2:通知用户新的版本号,以便可以在首次运行的时候对版本号进行更新处理
 Run,%SoftPath% %UpdateFinished% %Latest_Version%
}

 return true

}

;---------------------------------------------------------------------- 
println(text){
	local
	oSciTE:= ComObjActive("SciTE4AHK.Application")
	oSciTE.Output(text "`r`n")
	return
}

;---------------------------------------------------------------------- 

/*
TextContainingChieseUpDate(URL,newFilePath){ 
;目的是从网上下载带有中文ahk文件,如果直接下载的话，即使已经全局设置了UTF-8,中文依然显示不出来
	;有了更好的方案弃用了 - 11月30日
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

*/
;---------------------------------------------------------------------- 
