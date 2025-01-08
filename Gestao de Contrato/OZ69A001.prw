#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "fileio.ch"
#Include "FWMVCDef.ch"

#DEFINE MODEL_OPERATION_VIEW    2
#DEFINE MODEL_OPERATION_INSERT  3
#DEFINE MODEL_OPERATION_UPDATE  4
#DEFINE MODEL_OPERATION_DELETE  5
#DEFINE MODEL_OPERATION_COPY    9
#DEFINE MODEL_OPERATION_IMPR    8

/*/{Protheus.doc} OZ69A001
Rotina que importa os itens do contrato e gera uma nova revisão conforme os Dados para CSV.
@type function           
@author Ricardo Tavares Ferreira.
@since 20/01/2022
@version 12.1.27
@history 20/01/2022, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    User Function OZ69A001()
//=============================================================================================================================

    Local lConfirm 		:= .F. 

	Private cAliasCNB 	:= GetNextAlias()
	Private QbLinha		:= chr(13)+chr(10)

    While .T.
		If GetPerg()
			lConfirm := .T.
			Exit
		Else
			If MsgNoYes("Foi detectado o cancelamento do preechimento dos parametros. Deseja realmente sair da Importação do Arquivo (Sim / Não)?","Atenção !!!")
				Return Nil
			EndIf
		EndIf
	End
	If lConfirm 
		FWMsgRun(,{|oSay| GravaRev(oSay)},"Importação do Arquivo (Revisão). ","Importando o arquivo e Gerando a Revisão ...") 
	EndIf 
Return .T. 

/*/{Protheus.doc} GravaRev
Grava a revisão do contrato. 
@type function
@author Ricardo Tavares Ferreira
@since 20/01/2022
@version 12.1.27
@history 20/01/2022, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
	Static Function GravaRev(oSay)
//====================================================================================================

    Local oFile     := Nil
    Local aDados    := {}
    Local nX        := 0
    Local nZ        := 0
    Local aCampos   := {}
    Local aLinha    := {}
    Local oModel    := FWModelActive() 
    Local oStrCNB   := oModel:GetModel("CNBDETAIL")
    Local oView     := FWViewActive()

    oModel:Activate(.T.)
    oStrCNB:SetNoDeleteLine(.F.)
    oStrCNB:SetNoUpdateLine(.F.)
	oStrCNB:SetNoInsertLine(.F.)

    oStrCNB:ClearData(.F.,.T.)

    oFile := FWFileReader():New(Alltrim(MV_PAR01))
    If oFile:Open()
        aDados  := oFile:GetAllLines()
        aCampos := StrTokArr(aDados[1],";")

        For nX := 2 To Len(aDados)
            aLinha := StrTokArr(aDados[nX],";")
            If nX < Len(aDados)
                oStrCNB:AddLine()
            EndIf 
            oStrCNB:GoLine(nX - 1)
            For nZ := 1 To Len(aLinha)
                If TamSX3(aCampos[nZ])[3] == "C"
                    oStrCNB:SetValue(aCampos[nZ],Alltrim(aLinha[nZ]))
                ElseIf TamSX3(aCampos[nZ])[3] == "N"
                    oStrCNB:SetValue(aCampos[nZ],Val(aLinha[nZ]))
                ElseIf TamSX3(aCampos[nZ])[3] == "D"
                    oStrCNB:SetValue(aCampos[nZ],Stod(aLinha[nZ]))
                EndIf 
            Next nZ   
        Next nX
        oFile:Close()
    EndIf
    oView:Refresh()
Return Nil 

/*/{Protheus.doc} VlCampoObj
Valida campo obrigatorio.
@type function
@author Ricardo Tavares Ferreira
@since 20/01/2022
@version 12.1.27
@history 20/01/2022, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//==========================================================================================================
	Static Function VlCampoObj(cCampos)
//==========================================================================================================
	
	Local cCpos 	:= ""
	Local cNomeArq	:= ""

	SX3->(DbSetOrder(1))
	SX3->(DbSeek(Alltrim(Upper(MV_PAR04))))

	While .not. SX3->(Eof()) .and. SX3->X3_ARQUIVO $ Alltrim(Upper(MV_PAR04))
		If X3OBRIGAT(Alltrim(SX3->X3_CAMPO)) 
			cCpos += Alltrim(SX3->X3_CAMPO)+Chr(13)+Chr(10)
		EndIf
		SX3->(dbSkip())
	Enddo

	cNomeArq := Alltrim(MV_PAR02)+Alltrim(Upper(MV_PAR04))+Dtos(Date())+StrTran(Time(),":","")
	MemoWrite(cNomeArq+".txt",cCpos)
Return

/*/{Protheus.doc} GetPerg
Criacao das Perguntas da Rotina tipo Parambox. 
@type function
@author Ricardo Tavares Ferreira
@since 20/01/2022
@version 12.1.27
@return logical, Retorna logico se confirmou os paramtros.
@history 20/01/2022, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
	Static Function GetPerg()
//====================================================================================================

    Local aPergs	    := {}
    Local aRet		    := {}
    Local lRet		    := .T.
    Private cCadastro   := "Perguntas"

    aadd(aPergs,{6 ,"Local do Arquivo"      ,Padr("",300),"",".T.","",80,.T.,""/*"Arquivos CSV |*.csv"*/,"",GETF_LOCALHARD+GETF_NETWORKDRIVE}) // MV_PAR04

	If .not. ParamBox(aPergs,"Gerar Revisão",aRet,/*bValid*/,/*aButtons*/,.T.,/*nPosX*/,/*nPosY*/,/*oDialog*/,"OZ69A001",.T.,.T.)
		lRet := .F.
	EndIf 
Return lRet
