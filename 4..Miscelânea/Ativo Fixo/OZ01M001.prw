#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} OZ01M001
OZ01M001 - Rotina que valida os registros de importação do Dashboard Protheus x Grafana        
@type function
@author Ricardo Tavares Ferreira
@since 15/06/2023
@version 12.1.2210
@history 15/06/2023, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
	User Function OZ01M001()
//====================================================================================================

    Local lConfirm 	:= .F. 

    While .T.
		If GetPerg()
			lConfirm := .T.
			Exit
		Else
			If MsgNoYes("Foi detectado o cancelamento do preechimento dos parametros. Deseja realmente sair da Importação dos Dados (Sim / Não)?","Atenção !!!")
				Return Nil
			EndIf
		EndIf
	End
	If lConfirm 
		FWMsgRun(,{|oSay| ValidaReg(oSay)},"Verificando Integridade dos Dados. ","Gravando dados Validados ...") 
	EndIf 
Return Nil

/*/{Protheus.doc} ValidaReg
Função que valida os registros. 
@type function
@author Ricardo Tavares Ferreira
@since 15/06/2023
@version 12.1.2210
@history 15/06/2023, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
	Static Function ValidaReg(oSay)
//====================================================================================================

    Local oFile     := Nil
    Local aDados    := {}
    Local nX        := 0
    Local nY        := 0
    Local aCampos   := {}
    Local aLinha    := {}
    Local aRegFim   := {}
    Local aRegAux   := {}
    Local xValor    := Nil 
    Local aField    := {}
    Local cTab      := Alltrim(Upper(MV_PAR01))
    Local xVlAux    := Nil

    If .not. (Alltrim(Upper(MV_PAR01)) $ "SN1/SN3")
        MsgStop("A Tabela "+Alltrim(Upper(MV_PAR01))+", não está implementada para importação, Tabelas disponiveis (SN1|SN3). Não é possivel prosseguir.","Atenção")
        Return Nil 
    EndIf 

    DbSelectArea(cTab)

    oFile := FWFileReader():New(Alltrim(MV_PAR02))
    If oFile:Open()
        aDados  := oFile:GetAllLines()
        aCampos := StrTokArr(aDados[1],";")

        If SubStr(aCampos[1],1,2) <> SubStr(Alltrim(Upper(MV_PAR01)),2,2)
            MsgStop("O Arquivo selecionado nao faz referencia com a tabela selecionada, não é possivel prosseguir.","Atenção")
            Return Nil 
        EndIf 

        For nX := 1 To Len(aCampos)
            aField := FWSX3Util():GetFieldStruct(Alltrim(aCampos[nX]))
            If Len(aField) <= 0
                MsgStop("O campo "+aCampos[nX]+" não faz parte do dicionario de dados, não é possivel prosseguir.","Atenção")
                Return Nil 
            EndIf 
        Next nX 

        For nX := 2 To Len(aDados)
            aLinha := StrTokArr2(aDados[nX],";",.T.)
            For nY := 1 To Len(aLinha)
                If FWSX3Util():GetFieldType(aCampos[nY]) == "C"
                    xValor := Alltrim(aLinha[nY])
                ElseIf FWSX3Util():GetFieldType(aCampos[nY]) == "L"
                    xValor := .T.
                ElseIf FWSX3Util():GetFieldType(aCampos[nY]) == "D"
                    xValor := Stod(aLinha[nY])
                ElseIf FWSX3Util():GetFieldType(aCampos[nY]) == "M"
                    xValor := Alltrim(aLinha[nY])
                ElseIf FWSX3Util():GetFieldType(aCampos[nY]) == "N"  
                    xVlAux := StrTran(aLinha[nY],",",".")
                    xValor := Val(xVlAux)
                EndIf             
                aadd(aRegAux,{aCampos[nY],xValor})
            Next nY 
            aadd(aRegFim,aRegAux)
            aRegAux := {}
        Next nX

        oSay:cCaption := "Gravando dados Validados ..." 

        For nX := 1 To Len(aRegFim)
            RecLock(cTab,.T.)
                For nY := 1 To Len(aRegFim[nX])
                    &(cTab+"->"+aRegFim[nX][nY][1]) := aRegFim[nX][nY][2]
                Next nY
            If cTab == "SN1"
                SN1->(MsUnlock())
            ElseIf cTab == "SN3"
                SN3->(MsUnlock())
            EndIf 
        Next nX 
        oFile:Close()
    EndIf
    MsgInfo("Importação realizada com sucesso.", "Atenção")
Return Nil 

/*/{Protheus.doc} GetPerg
Criacao das Perguntas da Rotina tipo Parambox. 
@type function
@author Ricardo Tavares Ferreira
@since 15/06/2023
@version 12.1.2210
@return logical, Retorna logico se confirmou os paramtros.
@history 15/06/2023, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
	Static Function GetPerg()
//====================================================================================================

    Local aPergs	    := {}
    Local aRet		    := {}
    Local lRet		    := .T.

    aadd(aPergs,{1,"Tabela"	         , Space(3)	   , "" , "" , "" , "" , 50	, .T. } ) //MV_PAR01
    aadd(aPergs,{6,"Local do Arquivo", Padr("",300),"",".T.","",80,.T.,""/*"Arquivos CSV |*.csv"*/,"",GETF_LOCALHARD+GETF_NETWORKDRIVE}) // MV_PAR02

	If .not. ParamBox(aPergs,"Parametros",aRet,/*bValid*/,/*aButtons*/,.T.,/*nPosX*/,/*nPosY*/,/*oDialog*/,"OZ01M001",.T.,.T.)
		lRet := .F.
	EndIf 
Return lRet


//Layout SN1.csv
//Coluna
//N1_FILIAL;N1_CBASE;N1_ITEM;N1_DESCRIC;N1_QUANTD;N1_GRUPO;N1_AQUISIC;N1_NFISCAL;N1_NSERIE;N1_FORNEC;N1_PATRIM;N1_STATUS;N1_XLOCA;N1_LOJA;N1_XCEST
//Linha
//02;008200;0100;COMPLEMENTO MOINHO DE BOLAS ESTRUTURA EM ACO CARBONO DIM 5000X9000 MM MCA METSO MINERALS;1;1001;20151118;000001617;001;000030;N;1;RT;01;0002

//Layout SN3.csv
//Coluna
//N3_FILIAL;N3_CBASE;N3_ITEM;N3_BAIXA;N3_HISTOR;N3_TPSALDO;N3_CCONTAB;N3_CCDEPR;N3_VORIG1;N3_VRDACM1;N3_TXDEPR1;N3_VORIG2;N3_VRDACM2;N3_TXDEPR2;N3_AQUISIC;N3_DINDEPR;N3_TIPO;N3_TPDEPR;N3_CUSTBEM;N3_CCUSTO;N3_CCDESP;N3_CCCDEP;N3_SUBCTA;N3_SUBCCON;N3_SUBCDEP;N3_SUBCCDE;N3_SUBCDES;N3_SUBCCOR
//Linha
//06;000838;0002;0;INSERCAO PLANILHA MINARSKY - RT;1;120201004;120201004;12859,40; 2.786,16 ;20,00;2387,92;0,00;0,00;20200814;20200814;01;1;AVBCCSCGT;AVBCCSCGT;AVBCCSCGT;AVBCCSCGT;155;155;155;155;155;155
