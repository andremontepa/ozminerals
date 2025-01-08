#INCLUDE "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FA420NAR  �Autor  �Ismael Junior       � Data �  17/01/20   ���
�������������������������������������������������������������������������͹��
���Desc.     � Altera��o do nome da vari�vel cArqSaida na finaliza��o do  ���
���          � bordero                                                    ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 

User Function FA420NAR()

	Local cNomeAnt := "" // novo nome do arquivo de sa�da.
	Local lGeraFTP := GETMV("MV_XFTPCNA") //Faz upload do arquivo para o FTP?
	Local cCNABNU  := GETMV("MV_XCNABNU") //Sequencial do arquivo.  
	Local cCNABDT  := GETMV("MV_XCNABDT") //String com a data p/ uso no nome do arquivo.
	Local cCNABDI  := GETMV("MV_XCNABDI") //Diretorio do arquiv CNAB.
	Local cDia     := Day2Str(Date())
	Local cMes     := Month2Str(Date())
	Local cAno     := SubStr(Year2Str(Date()),3,2)
	//Local cChav  := cDia+cMes+cAno
	Local cChav    := cAno+cMes+cDia
	Local lCont    := .F.

	//Charles Lima - 08/06/2020 - Altera��o p/ criar as pastas caso n�o existam.
	If lGeraFTP
		cCNABDI := "\system\cnab\"
	Endif

	If ExistDir(cCNABDI, Nil, .T.)
		lCont   := .T.
	Else 
		MakeDir(cCNABDI, Nil, .T.)
		If ExistDir(cCNABDI, Nil, .T.)
			lCont := .T.
		Else
			Alert("N�o foi poss�vel criar o diret�tio: "+cCNABDI)
		Endif 
	Endif

	If lCont
		If cChav == cCNABDT
			nCNABNU := Val(cCNABNU)+1
			cCNABNU := Strzero(nCNABNU,2) 
			cNomeAnt := cCNABDI+cEmpAnt+cCNABDT+cCNABNU+".rem"
			PUTMV("MV_XCNABNU", cCNABNU)
			PUTMV("MV_XCNABDT", cCNABDT)	
		Else
			cCNABDT := cChav
			cCNABNU := "01"
			cNomeAnt := cCNABDI+cEmpAnt+cCNABDT+cCNABNU+".rem"
			PUTMV("MV_XCNABNU", cCNABNU)
			PUTMV("MV_XCNABDT", cCNABDT)
		Endif
	Endif

Return cNomeAnt
