/*◆
# Library 库名 : DownloadFileWithProgressBar

# Specification(Default ParaMeters)	功能介绍(默认参数下) :
	[请填写功能介绍]

# ParaMetersList	参数列表 :
	[示例参数列表]
	HayStack - 被搜索的字符串
	Count - 循环次数

# Author	& AHK Version	AHK版本&作者 :
	;提取自 https://github.com/ahkscript/ASPDM  @joedf 感谢

# Copyright  版权声明  :
	如果该文侵犯了您的权利，请联系我解决。
	欢迎转载/改变，如果您觉得我的分享有帮助，希望您能在作品上标注原文地址。

# Library Version 库版本 :
	v1.0 : DownloadFileWithProgressBar 的第一个版本上线了 O(∩_∩)O~

# 依赖库 :
	[请填写依赖库名]

# 常见问题 :
	有没有实战案例?
	一定有至少一个[11月21日起]
	如果有更多大型复杂案例会放在这里
	https://pan.baidu.com/s/1EHeg3MhQm5MRPgIR-l928Q

# Quality Test	出厂品控检测 :
	[请填写出厂品控检测结果]
*/

;带有进度条的文件下载
DownloadFileWithProgressBar(UrlToFile, SaveFileAs, Overwrite := True, UseProgressBar := True, ProgressBarTitle:="下载中...") { ;提取自 https://github.com/ahkscript/ASPDM  @joedf
  
  ;进度条展示次数计数,展示的次数越少，最后进度条停留的时间越长
  ShowerCounter:=0

    ;Check if the file already exists and if we must not overwrite it
      If (!Overwrite && FileExist(SaveFileAs))
          Return
    ;Check if the user wants a progressbar
      If (UseProgressBar) {
        
        ;提示正在连接服务器
          __UpdateProgressBar_o3()
          
          _surl:=ShortURL(UrlToFile)
          ;Initialize the WinHttpRequest Object
            WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
          ;Download the headers
            WebRequest.Open("HEAD", UrlToFile)
            WebRequest.Send()
          ;Store the header which holds the file size in a variable:
           ;获取文件大小，并且存入变量
          try{
            FinalSize := WebRequest.GetResponseHeader("Content-Length")
          }
          
          catch
          {
            ;throw Exception("could not get Content-Length for URL: " UrlToFile)
            Progress, CWFEFEF0 CT111111 CB468847 w330 h52 B1 FS8 WM700 WS700 FM8 ZH12 ZY3 C11, , %ProgressBarTitle%, %_surl%
            UrlDownloadToFile, %UrlToFile%, %SaveFileAs%
            Sleep 100
            Progress, Off
            return
          }
          ;Create the progressbar and the timer
            Progress, CWFEFEF0 CT111111 CB468847 w330 h52 B1 FS8 WM700 WS700 FM8 ZH12 ZY3 C11, , %ProgressBarTitle%, %_surl%
            SetTimer, __UpdateProgressBar, 100
      }
    ;Download the file
      UrlDownloadToFile, %UrlToFile%, %SaveFileAs%
      
    ;下载完成后移除计时器
      If (UseProgressBar) {
        ;下载结束之后就关掉进度条更新器
        SetTimer, __UpdateProgressBar, Off
        ;然后手动更新一次
        gosub __UpdateProgressBar
        ;看一下展示的时间,如果没有展示次数少于20次(2秒)，那么就让进度条多停留一会(至少让其停留两秒)
          ;为什么要至少停留两秒？就是因为爽,进度条一闪而过真他娘的不爽
            ;所以至少停两秒,爽,爽爽,爽爽爽,爽爽爽爽,爽爽爽爽爽,爽死了(我在这里不由自主的唱起了美丽的歌谣)。
              ;如果你看不懂我在说什么，那你就不用管了,你不是一个合格的复读机
                ;如果你已经唱起了歌,那你是个合格的复读机，恭喜你
        if (ShowerCounter<=20)
        delaytime:=(20-ShowerCounter)*100
        else 
        delaytime:=0
        Sleep,% delaytime+200
        ;关闭进度条
        Progress, Off          
      }
      ;返回任务完成的消息(如果想要更爽的话，那就在调用端设置更新成功的消息,不要错过这次机会,让用户爽爽爽的机会)
    return true
    
;---------------------------------------------------------------------- 

    ;The label that updates the progressbar
      __UpdateProgressBar:
         ;Get the current filesize and tick
            ShowerCounter++
            CurrentSize := FileOpen(SaveFileAs, "r").Length ;FileGetSize wouldn't return reliable results
            CurrentSizeTick := A_TickCount
          ;Calculate the downloadspeed
            ;Speed := Round((CurrentSize/1024-LastSize/1024)/((CurrentSizeTick-LastSizeTick)/1000)) . " Kb/s"
          ;Save the current filesize and tick for the next time
            ;LastSizeTick := CurrentSizeTick
            ;LastSize := FileOpen(SaveFileAs, "r").Length
          ;Calculate percent done
            PercentDone := Round(CurrentSize/FinalSize*100)
          ;Update the ProgressBar
          _csize:=Round(CurrentSize/1024,1)
          _fsize:=Round(FinalSize/1024)
            Progress, %PercentDone%, 下载中:  %_csize% KB / %_fsize% KB  [ %PercentDone%`% ], %_surl%
      Return
}

ShortURL(p,l=50) {
    VarSetCapacity(_p, (A_IsUnicode?2:1)*StrLen(p) )
    DllCall("shlwapi\PathCompactPathEx"
        ,"str", _p
        ,"str", p
        ,"uint", abs(l)
        ,"uint", 0)
    return _p
}