
;# EnableEscape是"开启转义"的意思
ReturnDate(Format,SimpleModel:=false,EnableEscape:=false){
	
	if (SimpleModel){ ;# 简洁模式IF开启
	
	;# 月日
if (Format="yr"){
	FormatTime, CurrentDateTime,,MM/dd
	return,% CurrentDateTime
}


;# 年月日
else if (Format="nyr"){
	FormatTime, CurrentDateTime,, yy/MM/dd
			return,% CurrentDateTime
}

;# 月日时分
else if (Format="yruf"){
	FormatTime, CurrentDateTime,,MM/dd_HH:mm
	}
	
;# 年月日时分
else if (Format="nyruf"){
	if EnableEscape
	{
		FormatTime, CurrentDateTime,,yy/MM/dd\_HH:mm
	return,% CurrentDateTime
	}
	FormatTime, CurrentDateTime,,yy/MM/dd_HH:mm
	return,% CurrentDateTime
	}
	
	
	} ;# 简洁模式IF结束


else if (SimpleModel=false){ ;#复杂模式ELSE开启
;# 月日
if (Format="yr"){
	FormatTime, CurrentDateTime,,MM月dd日
	return,% CurrentDateTime
}


;# 年月日
else if (Format="nyr"){
	FormatTime, CurrentDateTime,, yyyy年MM月dd日
			return,% CurrentDateTime
}

;# 月日时分
else if (Format="yruf"){
	FormatTime, CurrentDateTime,,MM月dd日_HH时mm分
	return,% CurrentDateTime
	}
	
;# 年月日时分
else if (Format="nyruf"){
	FormatTime, CurrentDateTime,,yyyy年MM月dd日_HH时mm分
	return,% CurrentDateTime
	}
	;# 年月日时分秒
else if (Format="nyrufm"){
	FormatTime, CurrentDateTime,,yyyy年MM月dd日_HH时mm分ss秒
	return,% CurrentDateTime
	}
	
		;# 日时分秒
else if (Format="rufm"){
	FormatTime, CurrentDateTime,,dd日_HH时mm分ss秒
	return,% CurrentDateTime
	}
	
;# 年月日时分(思维导图协作专用)xz=协作
else if (Format="xz"){
	FormatTime, CurrentDateTime,,yy/MM/dd_HH:mm
	return,% CurrentDateTime
	}
} ;# 复杂模式ElSE结束

	
;# 如果那么多条件筛选之后都没有出现return,那么很可能是格式错误
throw Exception("The Format Parameter Error")


}
