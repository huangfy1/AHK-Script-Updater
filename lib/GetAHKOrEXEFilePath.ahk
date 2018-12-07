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
	;相关参数初始化
	PathArray:=[],addToAHK:=0,addToExe:=0,EXECount:=0,AHKCount:=0
	
	;检测该软件的后缀名,便于之后判断目录下AHK文件是否多于1
	
	RegExMatch(A_ScriptName,"\.ahk$",RM)
	if (RM=".AHK"){
	addToAHK:=1
	;~ println("isahk")
	;~ MsgBox,isahk
	}
	
	RegExMatch(A_ScriptName,"\.exe$",RM) ;检测成功,可以实现
	if (RM=".EXE"){
	addToExe:=1
	;~ MsgBox,isexe
	}
	;~ ExitApp
	
	
Loop, Files, *.AHK
{
	AHKCount++
PathArray.Push(A_LoopFileLongPath)
if (AHKCount>1+addToAHK)
	throw Exception("SoftDir acquisition failed`r`nThe root directory contains multiple AHK files ")

} ;AHK文件循环结束

Loop, Files, *.EXE
{
	EXECount++
;~ EXEPath:=A_LoopFileLongPath
PathArray.Push(A_LoopFileLongPath)
;如果有多个EXE文件,报错
if (EXECount>1+addToExe) ;假设包含自身
	throw Exception("SoftDir acquisition failed`r`nThe root directory contains multiple EXE files ")
}

;如果没有发现任何EXE/AHK文件,报错
if (EXECount+AHKCount<=1) ;如果除了自身一个也没找到,就报错
	throw Exception("SoftDir acquisition failed`r`nEXE/AHK files are not included in the root directory ")

;如果有多个AHK/EXE文件,报错
if (EXECount+AHKCount>=3) ;除了自身之外，还有1个以上就报错
	throw Exception("SoftDir acquisition failed`r`nThe root directory contains multiple EXE/AHK files ")

;如果并非以上错误情况，那么意味着PathArray中仅有2个包含路径的元素,其中一个是该脚本本身,另外一个则是目标路径
 ;检查PathArray内元素数目,如果发现并非为2,则发出异常
	if (PathArray.Length()!=2)
		throw Exception("PathArray length is not two.")
	
 ;检查 "路径末端匹配" 的数据,并且去除
 ;得到"末端路径"
 MyCount:=0
 TheIndex:=0
 loop,% PathArray.Length(){
	MyCount++
	;一旦发现,某个路径的最后一步分和本文件的文件名是一致的,那么就写入其Index,并且break
	println(PathArray[MyCount])
	if (FilePathSplit(PathArray[MyCount])[2]=A_ScriptName){
		
		TheIndex:=MyCount
		break
	}

 }
 
 ;如果没有找到对应index
 if (TheIndex=0)
throw Exception("Not Found The Value Index.")
else if (TheIndex>2)
	throw Exception("The Index out of the Bounds.")
else  ;如果得到的index没有问题那么就移除
	RemovedValue := PathArray.RemoveAt(TheIndex)

if (PathArray.Length()!=1)
		throw Exception("PathArray length Exception.")

return PathArray[1] 

} ;函数结束
