/*◆
# Library 库名 : RegexEscape

# Specification(Default ParaMeters)	功能介绍(默认参数下) :
	转义函数字符串中含有的正则表达式特殊符号

# ParaMetersList	参数列表 :
	String 需要进行转义操作的字符串

# Author	& AHK Version	AHK版本&作者 :
	AHKv1.1.30 & 心如止水(QQ:2531574300)

# Copyright  版权声明  :
	如果该文侵犯了您的权利，请联系我解决。
	欢迎转载/改变，如果您觉得我的分享有帮助，希望您能在作品上标注原文地址。

# Library Version 库版本 :
	v1.0 : RegexEscape 的第一个版本上线了 O(∩_∩)O~

# 依赖库 :
	StringGroupParseToSimpleArray

# 常见问题 :
	有没有实战案例?
	一定有至少一个[11月21日起]
	如果有更多大型复杂案例会放在这里
	https://pan.baidu.com/s/1EHeg3MhQm5MRPgIR-l928Q

# Quality Test	出厂品控检测 :
	[请填写出厂品控检测结果]
*/

RegexEscape(String){
local
if (String="")
	return ;return 和 return "" 等价
;制造"正则特殊符号"数组
RegExvryi=|\|.|?|+|$|^|[|]|(|)|{|}|*|/| ;必须先转义’\‘,否则后面就麻烦了
TheArray:=StringGroupParseToSimpleArray(RegExvryi,Delimiters:="`|",EnableThrow=true,EnableMsgBoxPrint:=false,EnableTrim:=true,EnableDelimitersSingle:=true)
TheArray.push("|")
;遍历TheArray,如果发现有匹配,则全部替换为’\‘
TheCount:=0
loop,% TheArray.Length(){
TheCount++
sub:=TheArray[TheCount]
if instr(String,sub){
String:=StrReplace(String,sub,"\" . sub)
}
}
return String
}
