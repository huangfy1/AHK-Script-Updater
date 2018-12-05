#NoEnv
SetTitleMatchMode 2
#Hotstring EndChars  ◎
#Hotstring NoMouse
#SingleInstance force 
SetWorkingDir %A_ScriptDir%
FileEncoding , UTF-8

#Include %A_ScriptDir%\TaskDialog.ahk ;导入用户更新选择器(GUI)
#Include %A_ScriptDir%\lib\DownloadFileWithProgressBar.ahk ;导入下载器(GUI)
#Include %A_ScriptDir%\lib\Wait.ahk ;导入等待时的假进度条(GUI)

;---------------------------------------------------------------------- 
;建立配置文件的文件对象,如果不存在,则file为0
iniFile := FileOpen("AHKScriptUpdater.ini", "r")
if (iniFile=0){
	
	;如果不存在则建立配置文件"AHKScriptUpdater.ini"
BuildConfig("AHKScriptUpdater.ini")

	MsgBox,% 16+4,未找到配置文件,% "未能在软件根目录下找到配置文件 AHKScriptUpdater.ini" . "`r`n已在根目录下生成`r`n请完善相关参数之后再启动`r`n按下""是"",打开配置文件"
	
	IfMsgBox,Yes
		Run,AHKScriptUpdater.ini
	
	ExitApp
}

;如果没有发现配置文件，那么程序就会退出,如果没有退出的话，那就继续检查是否存在标签[Config] 
	;检查配置文件大小,如果超过1MB则不读取,防止程序假死
	if (iniFile.Length>1048576){
	MsgBox,% 16+4,配置文件大小异常,% "配置文件大小超过1MB" . "`r`n请检查 AHKScriptUpdater.ini 是否为标准的配置文件" . "按下""是"",建立一个标准配置文件demo,并且打开"
		IfMsgBox,Yes
		{
		BuildConfig("AHKScriptUpdater_Demo.ini")
		Run,AHKScriptUpdater_Demo.ini
		}

	ExitApp
	}
	
	;如果在正常范围之内则检查 Config 段名是否存在
	if !(InStr(iniFile.Read(),"[Config]")){
	MsgBox,% 16+4,配置文件段名异常,% "配置中没有发现 Config 段名" . "`r`n请检查 AHKScriptUpdater.ini 是否为标准的配置文件" . "按下""是"",建立一个标准配置文件demo,并且打开"
			IfMsgBox,Yes
		{
		BuildConfig("AHKScriptUpdater_Demo.ini")
		Run,AHKScriptUpdater_Demo.ini
		}
		
	ExitApp
	}
;config格式检查流程完毕,检查完成之后确保AHKScriptUpdater.ini存在,并且含有config段名
;---------------------------------------------------------------------- 

;# 读取配置
;## 必填参数

	;启动字符串(必填)
IniRead,FristParaMeter,AHKScriptUpdater.ini,Config,FristParaMeter ,% ""
	;请求者自身路径(必填) 
IniRead,SoftPath,AHKScriptUpdater.ini,Config,SoftPath,% ""
	;更新文件下载地址(必填)
IniRead,DownLoadURL,AHKScriptUpdater.ini,Config,DownLoadURL,% ""

;## 检查必填参数
s:=""
c:=0
if (FristParaMeter="")
	s.="FristParaMeter ",c++
if (SoftPath="")
	s.="SoftPath ",c++
if (DownLoadURL="")
	s.="DownLoadURL ",c++
;如果c不为0,那么说明必填参数有问题
if (c){
	MsgBox,% 16,配置文件中必填参数异常,% "配置文件中的" c "个必填参数" s "未填写"
ExitAPP
}

;---------------------------------------------------------------------- 


;## 非必填参数

	;版本文件下载地址(默认是在更新文件下载地址同目录下的Version.txt文件)
IniRead,Last_VersionURL,AHKScriptUpdater.ini, Config,Last_VersionURL ,% ""
	;当前版本号或地址
		;如果是由"数字和零或一个半角英文逗号(‘.’)"组成的字符串,则被直接看做版本号,否则会被看为本地版本文件路径
IniRead,Local_Version,AHKScriptUpdater.ini,Config,Local_Version ,% ""
	;更新临时文件地址(默认是原软件根目录下的%SoftDir%\CacheFile文件)
IniRead,TempFilePath,AHKScriptUpdater.ini,Config,TempFilePath,% ""

	;更新说明地址(如果不填,则不在用户选择框中显示)
IniRead,WikiURL,AHKScriptUpdater.ini,Config,WikiURL ,% ""

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

;---------------------------------------------------------------------- 

	;运行更新程序(该函数内变量为Globol模式)
Main_Updater(DownLoadURL,SoftPath,"",EnableCheckUpdate:=true,EnableBackup:=true,RunAfterUpdate:=true,UpdateVersionFile:=true)

return ;# 自动执行段结束
;---------------------------------------------------------------------- 
BuildConfig(FileName:="AHKScriptUpdater.ini"){
	local
;# 如果不存在的话 那么就写入一个新的配置 
	;生成字符串
Pairs= ;! 这个是不能包含空行的
(
;必填参数
FristParaMeter=Update
SoftPath=
DownLoadURL=
;非必填参数
Last_VersionURL=
Local_Version=
TempFilePath=
WikiURL=
)
	;在Config标签下,写入配置
IniWrite, %Pairs%,%FileName%, Config
}

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
/*
	刚刚接触COM组件调用相关的内容,感觉到非常困惑,网上的相关资料也不多
	比如说这个最简单的案例
	是怎么知道SciTE的COM组件名是"SciTE4AHK.Application"的呢?
	又是怎么知道它里面有一个方法叫做"Output"?
	
	大概查了一些资料，基本上对这上面的东西有了一点认识
	COM组件的信息是被放在注册表中的,当然具体怎么查询还搞不太清楚,感觉这方面的网上教程比较少，好像大多数的内容都在书里
	COM组件是一种设计的规范,是对调用者透明的,好像是有一个文件里面会讲到调用方法,找到之后先阅读这个文件，然后再调用
*/
	
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
