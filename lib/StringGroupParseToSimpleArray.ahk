/*

# StringGroupParseToSimpleArray 函数说明书(apidoc) AHK版本：	1.1.30
# 语言：中文
# 作者：心如止水<QQ:2531574300> <AHK持续学习者沙龙(928220639)> <Autohotkey高手群(348016704)>

## 功能介绍(默认下) :
把StringGroup切换为SimpleArray

## 参数介绍
### HayStack 待分割字符串
### Delimiters 分隔符(默认为"`|")
### EnableMsgBoxPrint 用MsgBox打印数组(默认为false)
### EnableTrim 删去两头的Delimiters
### EnableDelimitersSingle 删去重复的Delimiters
;---------------------------------------------------------------------------------------------------------------
# 借鉴
# 版本信息
v0.1 : 草创
*/
;---------------------------------------------------------------------------------------------------------------

/*
# 经验和花絮(非必须):我对 StringGroupParseToSimpleArray函数 的认识和学习过程
# 目的:
# 展望:
# 过程:
##
*/

StringGroupParseToSimpleArray(HayStack,Delimiters:="`|",EnableThrow=true,EnableMsgBoxPrint:=false,EnableTrim:=true,EnableDelimitersSingle:=true){
	local

	;# 检测是否为String,并且含有Delimiters 验收:
	;# 如果EnableThrow开启的话就抛出异常,关闭就原样返回(默认抛出异常).

	;## 检测是不是对象 √

if (IsObject(HayStack)){
		if (Enablethrow)
			throw Exception("First ParaMeter is not a String`r`n第一个参数并非字符串(但是是""对象"")")
		else
			return HayStack
	}

	;## 检测一下String中是否含有分隔符 √
	if NOT InStr(HayStack, Delimiters){
		if (Enablethrow)
			throw Exception("Not Find Delimiters in HayStack`r`n在您输入的字符串中，没有发现分隔符")
		else
			return [HayStack]
	}

	;# 确认无误之后，开始进行替换

	;# 如果发现有重复的，先变成一个(选项开启时)
	if (EnableDelimitersSingle){
		HayStack := RegExReplace(Haystack,"\|{2,}" , Replacement := "|", OutputVarCount := "", Limit := -1, StartingPosition := 1)
	}
	;# 如果发现头部和尾部有分隔符那么清除掉的(选项开启时)(清除两头的东西，要在清除重复的东西之后)
	;## 不需要用 `| 因为在这里根本就没有其易用，和不用是一样的效果
	if (EnableTrim){
		HayStack :=  Trim(HayStack,"|")
	}

	;## 建立空SimpleArray
	SimpleArray:=[]

	;## 解析字符串
	loop,Parse,HayStack,%Delimiters%
	{
		;## 加入数组中
		SimpleArray.Push(A_LoopField)
	}
	;## 用MsgBox打印数组(可选)
	if (EnableMsgBoxPrint)
		PrintArray(SimpleArray)
	return SimpleArray
}

/*
出厂检测信息:√
是√否×合格?
*/