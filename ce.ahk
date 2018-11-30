/*
# AHK标准表头开始

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#Warn ; # 加上错误检查机制,可以很大程度上避免由于AHK的灵活语法导致的逻辑错误
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
# AHK标准表头结束


^l::
        Progress, CWFEFEF0 CT0000FF CB468847 w330 h55 B1 FS8 WM700 WS700 FM13 ZH12 ZY3 C11, , % "正在连接服务器...`r`n请稍候..."
		            SetTimer, __UpdateProgressBar, 1500
return
*/



      __UpdateProgressBar_o1(){
		local
	  static WaitGUICount:=0
	  WaitGUICount++
	  mode := mod(WaitGUICount,3)
	  if (mode=0)
		point:="."
		else if (mode=1)
			point:=".."
				else if (mode=2)
			point:="..."
			else
				point:="程序好像出现了一点问题"
			s:="正在连接服务器" point "`r`n请稍候" point
       Progress, CWFEFEF0 CT0000FF CB468847 w330 h55 B1 FS8 WM700 WS700 FM13 ZH12 ZY3 C11, , % s
      Return
	  }
	  
	        __UpdateProgressBar_o2(){
		local
	  static WaitGUICount:=0
	  WaitGUICount++
	  mode := mod(WaitGUICount,3)
	  if (mode=0)
		point:="25"
		else if (mode=1)
			point:="50"
				else if (mode=2)
			point:="75"
			else
				point:="程序好像出现了一点问题"
			;~ s:="正在连接服务器" point "`r`n请稍候" point
       Progress,% point
      Return
	  }
	  
	        __UpdateProgressBar_o3(){
		local
		static count:=0
		count++
		if (count=1){
		Progress, b w200, 请稍候..., 正在连接服务器..., My Title
Progress, 50 ; 设置进度条的位置为 50%.
		}

      Return
	  }


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;#Include %A_ScriptDir%\lib\Include\声明本地库.ahk
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;