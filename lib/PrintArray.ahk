/*

# PrintArray函数说明书(apidoc)

## 功能介绍(默认下) :
打印数组

## 参数介绍
### 数组
;---------------------------------------------------------------------------------------------------------------
# 版本信息
v0.1 : 草创
v0.2 : 改TheArrayString.="[" 为 TheArrayString:="[" 防止#Warn报警
*/
;---------------------------------------------------------------------------------------------------------------

/*
# 经验和花絮(非必须):我对 PrintArray函数 的认识和学习过程
# 目的:
# 展望:
# 过程:
##

*/

 PrintArray(obj,EnableReturn:=false){
	local
	TheArrayString:="["
 For k, v in obj
{
 
    TheArrayString.="," v
	
}

;## 去掉最头上那个","
				TheArrayString := StrReplace(TheArrayString, "," , "", OutputVarCount,1)
				 TheArrayString.= "]"
				 if (EnableReturn)
					return TheArrayString
MsgBox % TheArrayString

 }
