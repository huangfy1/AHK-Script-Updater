/*◆
# Library 库名 : FilePathSplit

# Specification(Default ParaMeters)	功能介绍(默认参数下) :
输入FilePath输出由FileDir和FileName组成的Simple数组
比如 println(ArrayToString(FilePathSplit("D:\XDA\88888.jpg")))
输出的结果就是 [D:\XDA,88888.jpg]

# ParaMetersList	参数列表 :
FilePath

# Author	& AHK Version	AHK版本&作者 :
AHKv1.1.30 & 心如止水(QQ:2531574300)

# Copyright  版权声明  :
如果该文侵犯了您的权利，请联系我解决。
欢迎转载/改变，如果您觉得我的分享有帮助，希望您能在作品上标注原文地址。

# Library Version 库版本 :
v1.0 : FilePathSplit 的第一个版本上线了 O(∩_∩)O~

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
FilePathSplit(FilePath){
	;请求软件的根目录FileDir(不含结尾'\') 以及 请求软件的名字(含扩展名)
	FileDir:="null"
	FoundPos_0 := InStr(FilePath, "/" ,false,0,1)
	FoundPos_1 := InStr(FilePath, "\" ,false,0,1)
	;找到最后一个斜杠的位置
	FoundPos:=(FoundPos_0>=FoundPos_1)?FoundPos_0:FoundPos_1
	;提取出调用者本身的名字(前面带着斜杠),并且对可能存在的反斜杠转义
	FileName:=StrReplace(SubStr(FilePath,FoundPos),"\","\\")
	;使用正则替换掉调用者本身(使用正则仅仅替换掉最后一个被匹配的)
	FileDir:=RegExReplace(FilePath,"(" FileName ")$" )
	;去除正反斜杠得到真正的FileName
	FileName:=StrReplace((FileName:=StrReplace(FileName,"\","")),"/","")
	return [FileDir,FileName]
}
