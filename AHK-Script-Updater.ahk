#NoEnv
SetTitleMatchMode 2
#Hotstring EndChars  ◎
#Hotstring NoMouse
#SingleInstance force
SetWorkingDir %A_ScriptDir%
FileEncoding , UTF-8

#Include %A_ScriptDir%\TaskDialog.ahk ;导入用户更新选择器(Gui)
#Include %A_ScriptDir%\lib\DownloadFileWithProgressBar.ahk ;导入下载器(Gui)
#Include %A_ScriptDir%\lib\Wait.ahk ;导入等待时的假进度条(Gui)
;----------------------------------------------------------------------
;# 命令行参数

P1=%1% ;启动字符串
P2=%2% ;更新文件下载地址
P3=%3% ;请求者自身路径
;----------------------------------------------------------------------
;# 检查Config是否存在,如果不存在,则发出提示或者生成Demo文件
; 如果命令行参数P1/P2均存在,则跳过Config检查步骤。(其中有一个不存在，那就必须要检查Config)
if (P2="") OR (P1=""){

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

} ;config格式检查流程完毕,检查完成之后确保AHKScriptUpdater.ini存在,并且含有config段名。(如必选命令行参数已存在,则跳过检查)

;---------------------------------------------------------------------- 

;# 读取配置
;----------------------------------------------------------------------

;## 必填参数 

;启动字符串(必填)
;鉴于该参数的特殊性，可以通过命令行方式传入
;如果命令行中未传入,那么从Config获取

if (P1="")
	IniRead,FristParaMeter,AHKScriptUpdater.ini,Config,FristParaMeter ,% ""
else
	FristParaMeter:=P1

;更新文件下载地址(必填)
;鉴于该参数的特殊性，可以通过命令行方式传入
;如果命令行中未传入,那么从Config获取

if (P2="")
IniRead,DownLoadURL,AHKScriptUpdater.ini,Config,DownLoadURL,% ""
else
	DownLoadURL:=P2

;---------------------------------------------------------------------- 

;## 检查必填参数
s:=""
c:=0
if (FristParaMeter="")
	s.="FristParaMeter ",c++
if (DownLoadURL="")
	s.="DownLoadURL ",c++
;如果c不为0,那么说明必填参数有问题
if (c){
	MsgBox,% 16,配置文件中必填参数异常,% "配置文件中的" c "个必填参数" s "未填写"
	ExitApp
}
;---------------------------------------------------------------------- 


;## 非必填参数

;请求者自身路径
;默认为工作目录(升级程序根目录)exe/ahk文件,当目录下存在多个exe/ahk时报错
;鉴于该参数的特殊性，可以通过命令行方式传入
;如果命令行中未传入,那么从Config获取/或者使用默认配置
if (P3=""){
	IniRead,SoftPath,AHKScriptUpdater.ini,Config,SoftPath,% ""
	if (SoftPath=""){
		SoftPath:=GetAHKOrEXEFilePath()
	}
}
else{
	SoftPath=P3
}

println("SoftPath" . SoftPath)
;----------------------------------------------------------------------

;## 自动生成参数
SoftDir:=FilePathSplit(SoftPath)[1]
SoftName:=FilePathSplit(SoftPath)[2]
DownLoadRootURL:=FilePathSplit(DownLoadURL)[1]
;----------------------------------------------------------------------
;版本文件下载地址
;从配置文件读取
IniRead,LastVersionURL,AHKScriptUpdater.ini, Config,LastVersionURL ,% ""
;默认:在更新文件下载地址同目录下的Version.txt文件
; 如果值为空字串,提取文件更新URL根目录
if (LastVersionURL=""){
	LastVersionURL:=DownLoadRootURL . "/Version.txt"
	;~ println(LastVersionURL)
}
;如果不为空,假设用户输入了文件的下载地址,故不做任何处理


;----------------------------------------------------------------------

;当前版本号或地址
;如果是默认,那么假设本地地址存在于请求文件的根目录下的Version.txt文件
;如果用户填入数据上,则先做判断
;是由"数字和零或一个半角英文逗号(‘.’)"组成的字符串,则被直接看做版本号,否则会被看为本地版本文件路径
IniRead,LocalVersion,AHKScriptUpdater.ini,Config,LocalVersion ,% ""
;默认:请求文件的根目录下的Version.txt文件
; 如果值为空字串,请求文件的根目录
nf:="" ;用于后期检测"数字"使用,这里提前声明
if (LocalVersion=""){
	LocalVersion:=SoftDir . "/Version.txt"
	;~ println(LocalVersion)
}

;非默认:检查是否为"版本号"(由多个数字和一个.组成的字符串)
else {
	RegExMatch(LocalVersion,"^(-?\d+)(\.\d+)?$",nf)
}

;如果发现确实属于数字,那么不处理,如果不是那么读取文件到变量

if (LocalVersion!=nf) OR (LocalVersion=""){
;读取版本文件到变量
LocalVersionPath:=LocalVersion

try{
FileRead, LocalVersion, %LocalVersionPath%
}
catch {
throw Exception("Failed to read the file from path:" . LocalVersionPath)
}
println("LocalVersionPath" LocalVersionPath)
;读取完成之后再一次检查
	RegExMatch(LocalVersion,"^(-?\d+)(\.\d+)?$",nf)
if (LocalVersion!=nf) OR (LocalVersion=""){
		throw Exception("LocalVersion File Read Failed`r`nValue IS:"  LocalVersion)
		}
}

;Trim掉各种空白符
LocalVersion:=Trim(LocalVersion," `t`r`n`f`a`v`b")

println("LocalVersion:" LocalVersion)

;----------------------------------------------------------------------

;更新临时文件地址
;默认:原软件根目录下的%SoftDir%\CacheFile文件

IniRead,TempFilePath,AHKScriptUpdater.ini,Config,TempFilePath,% ""
;如果为空字串,那么就自动生成地址,否则就用用户传入的即可
if (TempFilePath="")
	TempFilePath:=SoftDir . "CacheFile"

;----------------------------------------------------------------------

;更新说明地址(如果不填,则不在用户选择框中显示,显示对话框时会检查)
IniRead,WikiURL,AHKScriptUpdater.ini,Config,WikiURL ,% ""

;----------------------------------------------------------------------
;调试

;~ println(LocalVersion),println(LastVersionURL),println(DownloadURL),println(WikiURL)

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
DownLoadURL=
;非必填参数
SoftPath=
LastVersionURL=
LocalVersion=
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
	;如果用户决定自动升级，那我们就拿到版本号
	LatestVersion:=CheckUpdate(LocalVersion,LastVersionURL,DownloadURL,D_Update,WikiURL)
}
;如果不检查更新的话，那么就直接下载即可
else
	%D_Update%()

;备份旧文件
if (EnableBackup){
	thedate:=returnDate(Format:="nyrufm")
	backuppath=%A_WorkingDir%\backup\%SoftName%_%thedate%.old
	FileCopy,%SoftPath%,%backuppath%
}

;用新的文件覆盖旧文件
FileCopy,%TempFilePath%,%SoftPath%,%true%
;删除临时文件
FileDelete,%TempFilePath%

;更新版本号文件(如果用户需要)
if (UpdateVersionFile!=false){
	;如果本地更新文件地址存在,那么就使用,如果不存在，那么就生成在请求文件的根目录下
	if(LocalVersionPath!="")
	VersionPath:=LocalVersionPath
	else
	VersionPath:=SoftDir . "\Version.txt"
	FileDelete,%VersionPath%
	;检查最新版本号是否为空,若并非为空，则写入
	if (LatestVersion="")
		throw Exception("Programme Cannot write to the local version file because did not get the latest version`r`nLatestVersion is null string")
	else
	FileAppend,%LatestVersion%,%VersionPath%
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


