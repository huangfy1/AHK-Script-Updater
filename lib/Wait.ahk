
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
