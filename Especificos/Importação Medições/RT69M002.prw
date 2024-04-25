#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "fileio.ch"

/*/{Protheus.doc} RT69M002
Rotina que importa os dados CSV e gera a medição.
@type class 
@author Ricardo Tavares Ferreira
@since 23/10/2021
@version 12.1.27
@history 23/10/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    User Function RT69M002()
//=============================================================================================================================

    Local lConfirm  := .F.
    Private oSay    := Nil 
    Private QbLinha	:= chr(13)+chr(10)

    While .T.
		If GetPerg()
            lConfirm := .T.
            Exit
		Else
			If MsgNoYes("Foi detectado o cancelamento do preechimento dos parametros. Deseja realmente sair da Importação das Provisões (Sim / Não)?","Atenção !!!")
				Return Nil
			EndIf
		EndIf
	End
    If lConfirm 
        FWMsgRun(,{|oSay| CriaMedicao(oSay)},"Criação da Medição","Criando medição de contrato...") 
    EndIf 
Return Nil

/*/{Protheus.doc} RT69M002
Rotina que importa os dados CSV e gera a medição.
@type class 
@author Ricardo Tavares Ferreira
@since 23/10/2021
@version 12.1.27
@history 23/10/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Static Function CriaMedicao(oSay)
//=============================================================================================================================

    Local oFile     := Nil 
    Local nLin      := 1
    Local aLinhas   := {}
    Local aCampos   := {}
    Local aDados    := {}

    oFile := FWFileReader():New(Alltrim(MV_PAR01))
    If oFile:Open()
        While oFile:hasLine()
            If nLin == 1 
                aCampos := CharToArray(oFile:GetLine(),";")
                nLin += 1
                Loop
            Else 
                aDados := CharToArray(oFile:GetLine(),";")
            EndIf 
            aadd(aLinhas,aDados)
            nLin += 1
        End
    Else
    	MsgStop(oFile:error():message,"Atenção")
    EndIf

    If Len(aCampos) > 0 .and. Len(aLinhas) > 0
        ExecutaMed(aCampos,aLinhas)
    EndIf 
Return Nil 

/*/{Protheus.doc} ExecutaMed
Rotina que importa os dados CSV e gera a medição.
@type class 
@author Ricardo Tavares Ferreira
@since 23/10/2021
@version 12.1.27
@history 23/10/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Static Function ExecutaMed(aCampos,aLinhas)
//=============================================================================================================================

    Local nX                := Nil 
    Local nY                := Nil 
    Local aItens            := {}
    Local aCab              := {}
    Local xCont             := Nil 
    Local aLinha            := {}
    Local cNumCont          := ""
    Local cRevisao          := ""
    Local cErroRet          := ""
    Local aLogAuto          := {}
    Local nQuant            := 0 
    Local nTotal            := 0
    Private lMSHelpAuto     := .T.
    Private lAutoErrNoFile  := .T.
    Private lMsErroAuto     := .F.

    For nX := 1 To Len(aLinhas)
        For nY := 1 To Len(aLinhas[nX])
            If Alltrim(aCampos[nY]) $ "CNE_DESCRI;CNE_UM;CN9_COMPET"
                xCont := Alltrim(Upper(aLinhas[nX][nY]))
            Else
                If TamSX3(aCampos[nY])[3] == "D"
                    xCont := Stod(aLinhas[nX][nY])
                ElseIf TamSX3(aCampos[nY])[3] == "N"
                    xCont := Val(StrTran(aLinhas[nX][nY],",","."))
                ElseIf TamSX3(aCampos[nY])[3] == "C"
                    xCont := Alltrim(Upper(aLinhas[nX][nY]))
                EndIf 
            EndIf 
            If Alltrim(aCampos[nY]) == "CNE_QUANT"
                nQuant := xCont
            EndIF 
            If Alltrim(aCampos[nY]) == "CNE_VLUNIT"
                If nQuant > 0
                    nTotal := nQuant * xCont
                EndIf 
            EndIF 
            If nX == 1
                If Alltrim(aCampos[nY]) == "CN9_NUMERO"
                    aadd(aCab,{"CND_CONTRA",xCont,NIL})
                    cNumCont := Alltrim(xCont)
                ElseIf Alltrim(aCampos[nY]) == "CN9_REVATU"
                    aadd(aCab,{"CND_REVISA",xCont,NIL})
                     cRevisao := Alltrim(xCont)
                ElseIf Alltrim(aCampos[nY]) == "CN9_COMPET"
                    xCont := SubStr(xCont,5,2)+"/"+SubStr(xCont,1,4)
                    aadd(aCab,{"CND_COMPET",xCont,NIL})
                ElseIf Alltrim(aCampos[nY]) == "CNE_NUMERO"
                    aadd(aCab,{"CND_NUMERO",xCont,NIL})
                    aadd(aCab,{"CND_PARCEL","1",NIL})
                ElseIf Alltrim(aCampos[nY]) == "CND_FORNEC"
                    aadd(aCab,{"CND_FORNEC",xCont,NIL})
                ElseIf Alltrim(aCampos[nY]) == "CND_LJFORN"
                    aadd(aCab,{"CND_LJFORN",xCont,NIL})
                ElseIf Alltrim(aCampos[nY]) == "CND_CLIENT"
                    aadd(aCab,{"CND_CLIENT",xCont,NIL})
                ElseIf Alltrim(aCampos[nY]) == "CND_LOJACL"
                    aadd(aCab,{"CND_LOJACL",xCont,NIL})
                Else 
                    If Alltrim(aCampos[nY]) $ "CNE_ITEM;CNE_PRODUT;CNE_QUANT;CNE_CC;CNE_ITEMCT;CNE_CLVL;CNE_VLUNIT" 
                        If Alltrim(aCampos[nY]) == "CNE_VLUNIT"
                            aadd(aLinha,{"CNE_VLTOT",nTotal,NIL})
                            aadd(aLinha,{Alltrim(aCampos[nY]),xCont,NIL})
                        ElseIf Alltrim(aCampos[nY]) == "CNE_CC"
                            aadd(aLinha,{"CNE_XCC",xCont,NIL})
                            aadd(aLinha,{Alltrim(aCampos[nY]),xCont,NIL})
                        ElseIf Alltrim(aCampos[nY]) == "CNE_ITEMCT"
                            aadd(aLinha,{"CNE_XITCTA",xCont,NIL})
                            aadd(aLinha,{Alltrim(aCampos[nY]),xCont,NIL})
                        ElseIf Alltrim(aCampos[nY]) == "CNE_CLVL"
                            aadd(aLinha,{"CNE_XCLVL",xCont,NIL})
                            aadd(aLinha,{Alltrim(aCampos[nY]),xCont,NIL})
                        Else 
                            aadd(aLinha,{Alltrim(aCampos[nY]),xCont,NIL})
                        EndIf
                    EndIF  
                EndIf 
            Else 
                If Alltrim(aCampos[nY]) $ "CNE_ITEM;CNE_PRODUT;CNE_QUANT;CNE_CC;CNE_ITEMCT;CNE_CLVL;CNE_VLUNIT" 
                    If Alltrim(aCampos[nY]) == "CNE_VLUNIT"
                        aadd(aLinha,{"CNE_VLTOT",nTotal,NIL})
                        aadd(aLinha,{Alltrim(aCampos[nY]),xCont,NIL})
                    ElseIf Alltrim(aCampos[nY]) == "CNE_CC"
                        aadd(aLinha,{"CNE_XCC",xCont,NIL})
                        aadd(aLinha,{Alltrim(aCampos[nY]),xCont,NIL})
                    ElseIf Alltrim(aCampos[nY]) == "CNE_ITEMCT"
                        aadd(aLinha,{"CNE_XITCTA",xCont,NIL})
                        aadd(aLinha,{Alltrim(aCampos[nY]),xCont,NIL})
                    ElseIf Alltrim(aCampos[nY]) == "CNE_CLVL"
                        aadd(aLinha,{"CNE_XCLVL",xCont,NIL})
                        aadd(aLinha,{Alltrim(aCampos[nY]),xCont,NIL})
                    Else
                        aadd(aLinha,{Alltrim(aCampos[nY]),xCont,NIL})
                    EndIf 
                EndIF 
            EndIF  
        Next nY 
        If Len(aLinha) > 0 
            aadd(aLinha,{"CNE_REVISA",cRevisao,NIL})
            aLinha := FWVetByDic(aLinha,"CNE")
            aadd(aItens,aLinha)
        EndIf 
        aLinha := {}
    Next nX

    MSExecAuto({|x,y|CNTA120(x,y,3,.F.)},aCab, aItens) //Executa rotina automatica para gerar as medicoes

    If lMsErroAuto
    MostraErro()
        aLogAuto := GetAutoGRLog()
        For nY := 1 To Len(aLogAuto)
            cErroRet += aLogAuto[nY] +QbLinha
        Next nY
        cMsg := "Falha na Execução do ExecAuto ERRO -> "+cErroRet        
    Else        
        cMsg := "Medição incluida com sucesso Dados:" +QbLinha
        cMsg += "Filial: "+Alltrim(CND->CND_FILIAL)+QbLinha
        cMsg += "Num. Medição: "+Alltrim(CND->CND_NUMMED)+QbLinha
    Endif
    MsgInfo(cMsg,"Atenção")
Return Nil 

/*/{Protheus.doc} CharToArray
Converte Caracter em Array
@type function
@author Ricardo Tavares Ferreira
@since 28/06/2021
@version 12.1.27
@return array, Array da linha tratada.
@history 21/06/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
	Static Function CharToArray(cLinha,cSepar)
//====================================================================================================
    
    Local nPos     := 0
    Local aLinha   := {}

    nPos := At(cSepar,cLinha)
    While !Empty(cLinha)  .And. nPos > 0
        Aadd(aLinha,SubStr(cLinha,1,nPos-1))
        cLinha  := Subs(cLinha,nPos+1,Len(cLinha)-nPos)
        nPos    := At(cSepar,cLinha)
        If nPos = 0 .And. !Empty(cLinha)
            nPos := Len(cLinha)+1
        Endif
    Enddo
Return aLinha

/*/{Protheus.doc} GetPerg
Criacao das Perguntas da Rotina tipo Parambox. 
@type function
@author Ricardo Tavares Ferreira
@since 28/06/2021
@version 12.1.27
@return logical, Retorna logico se confirmou os paramtros.
@history 21/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
	Static Function GetPerg()
//====================================================================================================

    Local aPergs	    := {}
    Local aRet		    := {}
    Local lRet		    := .T.
    Private cCadastro   := "Perguntas"

    aadd(aPergs,{6,"Local do Arquivo",Padr("",300),"",".T.","",80,.T.,""/*"Arquivos CSV |*.csv"*/,"",GETF_LOCALHARD+GETF_NETWORKDRIVE}) // MV_PAR01

	If .not. ParamBox(aPergs,"Buscar Arquivo",aRet,/*bValid*/,/*aButtons*/,.T.,/*nPosX*/,/*nPosY*/,/*oDialog*/,"RT69M002",.T.,.T.)
		lRet := .F.
	EndIf 
Return lRet
