
;# EnableEscape��"����ת��"����˼
ReturnDate(Format,SimpleModel:=false,EnableEscape:=false){
	
	if (SimpleModel){ ;# ���ģʽIF����
	
	;# ����
if (Format="yr"){
	FormatTime, CurrentDateTime,,MM/dd
	return,% CurrentDateTime
}


;# ������
else if (Format="nyr"){
	FormatTime, CurrentDateTime,, yy/MM/dd
			return,% CurrentDateTime
}

;# ����ʱ��
else if (Format="yruf"){
	FormatTime, CurrentDateTime,,MM/dd_HH:mm
	}
	
;# ������ʱ��
else if (Format="nyruf"){
	if EnableEscape
	{
		FormatTime, CurrentDateTime,,yy/MM/dd\_HH:mm
	return,% CurrentDateTime
	}
	FormatTime, CurrentDateTime,,yy/MM/dd_HH:mm
	return,% CurrentDateTime
	}
	
	
	} ;# ���ģʽIF����


else if (SimpleModel=false){ ;#����ģʽELSE����
;# ����
if (Format="yr"){
	FormatTime, CurrentDateTime,,MM��dd��
	return,% CurrentDateTime
}


;# ������
else if (Format="nyr"){
	FormatTime, CurrentDateTime,, yyyy��MM��dd��
			return,% CurrentDateTime
}

;# ����ʱ��
else if (Format="yruf"){
	FormatTime, CurrentDateTime,,MM��dd��_HHʱmm��
	return,% CurrentDateTime
	}
	
;# ������ʱ��
else if (Format="nyruf"){
	FormatTime, CurrentDateTime,,yyyy��MM��dd��_HHʱmm��
	return,% CurrentDateTime
	}
	;# ������ʱ����
else if (Format="nyrufm"){
	FormatTime, CurrentDateTime,,yyyy��MM��dd��_HHʱmm��ss��
	return,% CurrentDateTime
	}
	
		;# ��ʱ����
else if (Format="rufm"){
	FormatTime, CurrentDateTime,,dd��_HHʱmm��ss��
	return,% CurrentDateTime
	}
	
;# ������ʱ��(˼ά��ͼЭ��ר��)xz=Э��
else if (Format="xz"){
	FormatTime, CurrentDateTime,,yy/MM/dd_HH:mm
	return,% CurrentDateTime
	}
} ;# ����ģʽElSE����

	
;# �����ô������ɸѡ֮��û�г���return,��ô�ܿ����Ǹ�ʽ����
throw Exception("The Format Parameter Error")


}
