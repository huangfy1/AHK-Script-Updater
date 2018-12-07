/*◆
# Library 库名 : CheckUpdate

# Specification(Default ParaMeters)	功能介绍(默认参数下) :
检查更新,并且弹出对话框询问用户的下一步操作
若用户决定自动升级，则返回LatestVersion(最新版本号)

# ParaMetersList	参数列表 :
LocalVersion 当前本地版本号(纯数字字符串)
LastVersionURL 新版本文件URL(纯数字文本文件)
如果输入的内容不带有http,那么即认为输入的就版本本身而不是URL
DownloadURL 新版本下载URL
[D_Update]  当用户选择"自动更新"时触发的函数
支持函数对象和函数名
如果不填的话，那么就只是返回0/1,1代表用户选择了自动更新,0代表用户选择了其他选项
[WikiURL]  更新信息URL

# Author	& AHK Version	AHK版本&作者 :
;由心如止水,改编自https://github.com/h0ll0w-v0id/AHK_Updater 感谢h0ll0w-v0id 的分享
(原来的作用是检查AutoHotKey本身是否有更新,主要是界面很友好,改了改直接来用了)

# Copyright  版权声明  :
如果该文侵犯了您的权利，请联系我解决。
欢迎转载/改变，如果您觉得我的分享有帮助，希望您能在作品上标注原文地址。

# Library Version 库版本 :
v1.0 : CheckUpdate 的第一个版本上线了 O(∩_∩)O~

# 依赖库 :
[请填写依赖库名]

# 常见问题 :
有没有实战案例?
一定有至少一个[11月21日起]
如果有更多大型复杂案例会放在这里
https://pan.baidu.com/s/1EHeg3MhQm5MRPgIR-l928Q

# Quality Test	出厂品控检测 :
√ 质量合格 QS
*/

CheckUpdate(LocalVersion,LastVersionURL,DownloadURL,D_Update:="null",WikiURL=""){

	;假设全局本地模式
	local
	;版本号是全局的(便于更新完成之后写入)
	global  LatestVersion

	;检查D_Update是否为对象
	if !(IsObject(D_Update)){
		if !(D_Update="null")
		;不是对象就生成对象
			D_Update:=Func(D_Update)
	}
        ;提示正在连接服务器
          __UpdateProgressBar_o3()
		  
	;检查LastVersionURL是否含有HTTP
	if (InStr(LastVersionURL,"http")){
		;如果有就下载它到变量Contents
		whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		whr.Open("GET", LastVersionURL, true)
		whr.Send()
		whr.WaitForResponse()
		Contents := whr.ResponseText
        ;关闭正在连接服务器的提示
		Progress,Off
		; 如果下载成功就赋值给LatestVersion
		if (Contents!=""){
			LatestVersion := Contents
		}
		else{
			;如果下载失败就抛出异常
			println("Is" Contents)
			println("Is" LastVersionURL)
			throw Exception("Version File Download Failed `r`n" . LastVersionURL)
		}
	}
	;如果不含有HTTP,那么就直接作为版本号来使用
	else{
		LatestVersion := LastVersionURL
	}

	;对版本号,去除空白符
	LatestVersion:=RegExReplace(LatestVersion,"\s","")

	;----------------------------------------------------------------------

	; 检查是否需要更新

	if (LocalVersion<LatestVersion){
		; 检查wiki是否存在,如果存不存在那么干脆就不显示该选项
		if (wiki=""){
			wiki:=-1
			iButtonID := TaskDialog(0, "软件升级||发现新版本" . "||本地版本 v" LocalVersion, "自动下载并更新到 v" LatestVersion . "`n点击立即更新" . "|手动下载最新版本 v" LatestVersion . "`n点击打开网站"  . "|退出`nExit", 0x10, "GREY")
		}

		else{
			wiki:=0
			iButtonID := TaskDialog(0, "软件升级||发现新版本" . "||本地版本 v" LocalVersion, "自动下载并更新到 v" LatestVersion . "`n点击立即更新" . "|手动下载最新版本 v" LatestVersion . "`n点击打开网站"  . "|查看更新信息`n点击打开网站" . "|退出`nExit", 0x10, "GREY")
		}


		if ( iButtonID == 1001 ){
			if (D_Update="null")
				return true
			else{
				;运行自动更新程序(函数对象)
				%D_Update%()
				return LatestVersion
			}
		}

		if ( iButtonID == 1002 ){
			Run, DownloadURL
			ExitApp
		}

		else if ( iButtonID == 1004+wiki ){
			ExitApp
		}

		else if ( iButtonID == 1003 ){
			Run, WikiURL
			ExitApp
		}
	}
	; 如果已经是最新版
	else if ( LocalVersion >= LatestVersion ){
		iButtonID := TaskDialog("", "升级|| 当前版本已经是最新版本"
		. "`n||本地版本 v" LocalVersion "  最新版本 v" LatestVersion, "退出 Exit", 0x10, "GREEN")

		; custom button 1 - set to close
		if ( iButtonID == 1001 ){
			ExitApp
		}
	}
	ExitApp
} ;UpdateCheck函数结束

