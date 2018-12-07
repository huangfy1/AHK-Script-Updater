/*◆
# Library 库名 : GetAHKOrEXEFilePath

# Specification(Default ParaMeters)	功能介绍(默认参数下) :
	获取工作目录下的EXE/AHK文件路径并返回,如果发现多个AHK/EXE文件则报错

# ParaMetersList	参数列表 :
	无参

# Author	& AHK Version	AHK版本&作者 :
	AHKv1.1.30 & 心如止水(QQ:2531574300)

# Copyright  版权声明  :
	如果该文侵犯了您的权利，请联系我解决。
	欢迎转载/改变，如果您觉得我的分享有帮助，希望您能在作品上标注原文地址。

# Library Version 库版本 :
	v1.0 : GetAHKOrEXEFilePath 的第一个版本上线了 O(∩_∩)O~

# 依赖库 :
	[请填写依赖库名]

# 常见问题 :
	有没有实战案例?
	一定有至少一个[11月21日起]
	如果有更多大型复杂案例会放在这里
	https://pan.baidu.com/s/1EHeg3MhQm5MRPgIR-l928Q

# Quality Test	出厂品控检测 :
	[请填写出厂品控检测结果] √
*/


GetAHKOrEXEFilePath(){
	local
	
Loop, Files, *.AHK
{
AHKPath:=A_LoopFilePath

;如果有多个AHK文件,报错
if (A_Index>1)
	throw Exception("SoftDir acquisition failed`r`nThe root directory contains multiple AHK files ")

} ;AHK文件循环结束

Loop, Files, *.EXE
{
EXEPath:=A_LoopFilePath
;如果有多个EXE文件,报错
if (A_Index>1)
	throw Exception("SoftDir acquisition failed`r`nThe root directory contains multiple EXE files ")
}

;如果没有发现任何EXE/AHK文件,报错
if (EXEPath="") AND (AHKPath="")
	throw Exception("SoftDir acquisition failed`r`nEXE/AHK files are not included in the root directory ")
;如果有多个AHK/EXE文件,报错
if (EXEPath!="") AND (AHKPath!="")
	throw Exception("SoftDir acquisition failed`r`nThe root directory contains multiple EXE/AHK files ")

;如果并非以上错误情况，那么意味着EXEPath/AHKPath中仅有一个包含路径，另外一个为空字符串，所以可以通过字符串拼接的方法把所需路径生成
Path:=EXEPath . AHKPath
;~ println(Path)
return Path

} ;函数结束
