#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PRTOPDEF.CH"
#INCLUDE "font.ch"

/*/{Protheus.doc} CNTA121
Ponto de Entrada em MVC para a Medi��o de Contratos.
@type function
@author Ricardo Tavares Ferreira
@since 25/04/2022
@version 12.1.33
@obs Ponto de Entrada Substituidos no processo:
    CN120ENVL - Permite validar o encerramento da medi��o
    CN120VENC - Encerramento da medi��o
    CN120VEST - Ponto de entrada para tratamento antes de efetuar o estorno da medi��o.
@history 25/04/2022, Ricardo Tavares Ferreira, Constru��o Inicial
@return object, Retorna o Objeto do Browse.
/*/
//=============================================================================================================================
    User Function CNTA121()
//=============================================================================================================================

    Local aParam    := PARAMIXB
    Local xRet      := .T.
    Local oModel    := Nil 
    Local cIdPonto  := ""
    Local cIdModel  := ""
    Local aRet      := {}
    Local cMsg      := ""
 
    If aParam <> NIL
        oModel  := aParam[1]
        cIdPonto:= aParam[2]
        cIdModel:= aParam[3]

        dbSelectArea("CN9")
	    CN9->(dbSetOrder(1))
	    //If .not. CN9->(dbSeek(CND->CND_FILIAL + CND->CND_CONTRA + CND->CND_REVISA))
        //    Help("",1,"CN120VENC",,"N�o foi poss�vel encontrar o contrato nesta filial. Verifique se est� na filial de origem do contrato.",1,1)
        //    Return .F.
        //EndIf 
        /*O evento de id <MODELVLDACTIVE> ser� sempre chamado ao iniciar uma opera��o com o modelo de dados via m�todo Activate do MPFormModel,
        ent�o para nos certificarmos que a valida��o s� ser� executada no encerramento tal qual o p.e CN120ENVL, � necess�rio verificar se a chamada est� sendo realizada
        atrav�s da fun��o CN121MedEnc, pra isso utilizamos a fun��o FwIsInCallStack
         */
        If cIdPonto == 'MODELVLDACTIVE' .And. FwIsInCallStack("CN121MedEnc")
            /*Como o modelo ainda n�o foi ativado, devemos utilizar as tabelas p/ valida��o, a �nica informa��o que constara em oModel
            ser� a opera��o(obtida pelo m�todo GetOperation), que nesse exemplo sempre ser� MODEL_OPERATION_UPDATE.                
            */
            xRet := ValEnvl()
            If .not. xRet
                Help("",1,"CN120ENVL",,"N�o e permitido estornar ou encerrar por esta rotina um contrato Nacional. Verifique!",1,1)
                Return xRet
            EndIf 

            aRet := ValVenc()
            xRet := aRet[1]
            cMsg := aRet[2]
            If .not. xRet
                Help("",1,"CN120VENC",,cMsg,1,1)
                Return xRet
            EndIf 
        ElseIf cIdPonto == 'MODELVLDACTIVE' .and. FwIsInCallStack("CN121Estorn")
            xRet := ValVEst()
            If .not. xRet
                Help("",1,"CN120VEST",,"N�o e permitido estornar ou encerrar por esta rotina um contrato Nacional. Verifique!",1,1)
                Return xRet
            EndIf 
        EndIf
    EndIf
Return xRet

/*/{Protheus.doc} ValVEst
Fun��o com a Valida��o que era executada no ponto de entrada CN120VEST.
@type function
@author Ricardo Tavares Ferreira
@since 25/04/2022
@version 12.1.33
@history 25/04/2022, Ricardo Tavares Ferreira, Constru��o Inicial
@return object, Retorna o Objeto do Browse.
/*/
//=============================================================================================================================
    Static Function ValVEst()
//=============================================================================================================================

    If Alltrim(Upper(CN9->CN9_XGLOBA)) == "N" .and. .not. FwIsInCallStack("U_IACOMP02")
        Return .F.
    EndIf 
Return .T.

/*/{Protheus.doc} ValEnvl
Fun��o com a Valida��o que era executada no ponto de entrada CN120ENVL.
@type function
@author Ricardo Tavares Ferreira
@since 25/04/2022
@version 12.1.33
@history 25/04/2022, Ricardo Tavares Ferreira, Constru��o Inicial
@return logical, Retorna Verdadeiro se prossegue com a opera��o.
/*/
//=============================================================================================================================
    Static Function ValEnvl()
//=============================================================================================================================

    If Alltrim(Upper(CN9->CN9_XGLOBA)) == "N" .and. .not. FwIsInCallStack("U_IACOMP01")
        Return .F.
    EndIf 
Return .T.

/*/{Protheus.doc} ValVenc
Fun��o com a Valida��o que era executada no ponto de entrada CN120VENC.
@type function
@author Ricardo Tavares Ferreira
@since 25/04/2022
@version 12.1.33
@history 25/04/2022, Ricardo Tavares Ferreira, Constru��o Inicial
@return logical, Retorna Verdadeiro se prossegue com a opera��o.
/*/
//=============================================================================================================================
    Static Function ValVenc()
//=============================================================================================================================
    Local cMsg      := ""
    Local _dData    := cTod("//")
    Local aDados    := {}
    Local xCusto    := ""
    Local xItemC    := ""
    Local xClass    := ""
    //Local cFilial   := CND->CND_FILIAL  // Filial
   // Local cContra   := CND->CND_CONTRA  // Numero Contrato
   // Local cRevisa   := CND->CND_REVISA  // Numero Revis�o
   // Local cNumero   := "000001"  // Numero Medi��o
   // Local cItemme   := "001"  // Item da Medi��o
   // Local cMedica   := CND->CND_NUMMED  // Numero Medi��o
    Local cTab      := "CN9"

    aDados := GetEntContab(Alltrim(CND->CND_FILIAL),Alltrim(CND->CND_CONTRA),Alltrim(CND->CND_REVISA),AllTrim(CND->CND_NUMMED))

    If Len(aDados) > 0 
        xCusto := aDados[1]
        xItemC := aDados[2]
        xClass := aDados[3]
    EndIf 

    If .not. AVBUtil():ValidaGrupoAprovacao(cTab,xCusto,xItemC,xClass)[1]
        cMsg := "N�o � possivel incluir uma SC sem Entidades contabeis amarradas para aprova��o."
        Return {.F.,cMsg}
    EndIf 

    _dData := DaySum(CN9->CN9_DTFIM,30)     
		    
    If dDatabase > _dData
	    cMsg := "A medi��o n�o pode ser encerrada, pois o contrato encontra-se vencido"
        Return {.F.,cMsg}	   																			
    EndIf                 
Return {.T.,cMsg}

/*/{Protheus.doc} GetEntContab
Busca dos dados da entidade contabil.
@type function 
@author Ricardo Tavares Ferreira
@version 12.1.27
@return array, Array com os dados da entidade contabil.
@since 15/03/2022
@history 15/03/2022, Ricardo Tavares Ferreira, Constru��o Inicial.
/*/
//=============================================================================================================================
    Static Function GetEntContab(xFil,xNumCtr,xRevCtr,xNumMed)
//=============================================================================================================================

    Local xCusto      := ""
    Local xItemC      := ""
    Local xClass      := ""
	Local QbLinha		:= chr(13)+chr(10)
	Local cAliasCNE	:= GetNextAlias()
	Local cQuery		:= ""
	Local nQtdReg  	:= 0
    Local aDadosCNZ   := {}

    cQuery := " SELECT "+QbLinha 

    If Alltrim(CN9->CN9_XGLOBA) == "N" .and. Alltrim(CND->CND_XEMPRE)+Alltrim(CND->CND_XFILIA) <> Alltrim(cEmpAnt)+Alltrim(CND->CND_FILIAL)
        cQuery += " CNE_XCC CNE_CC "+QbLinha  
        cQuery += " ,CNE_XITCTA CNE_ITEMCT "+QbLinha  
        cQuery += " ,CNE_XCLVL CNE_CLVL "+QbLinha 
    Else
        cQuery += " CNE_CC "+QbLinha  
        cQuery += " ,CNE_ITEMCT "+QbLinha  
        cQuery += " ,CNE_CLVL "+QbLinha  
    EndIf

	cQuery += " FROM "
	cQuery +=   RetSqlName("CNE") + " CNE "+QbLinha 
    cQuery += " WHERE "+QbLinha  
    cQuery += " CNE.D_E_L_E_T_ = ' ' "+QbLinha  
    cQuery += " AND CNE_FILIAL = '"+xFil+"' "+QbLinha  
    cQuery += " AND CNE_CONTRA = '"+xNumCtr+"' "+QbLinha 
    cQuery += " AND CNE_REVISA = '"+xRevCtr+"' "+QbLinha 
    cQuery += " AND CNE_NUMMED = '"+xNumMed+"' "+QbLinha 

    If Alltrim(CN9->CN9_XGLOBA) == "N" .and. Alltrim(CND->CND_XEMPRE)+Alltrim(CND->CND_XFILIA) <> Alltrim(cEmpAnt)+Alltrim(CND->CND_FILIAL)
        cQuery += " AND CNE_XCC <> ' ' "+QbLinha  
        cQuery += " AND CNE_XITCTA <> ' ' "+QbLinha  
        cQuery += " AND CNE_XCLVL <> ' ' "+QbLinha 
    Else
        cQuery += " AND CNE_CC <> ' ' "+QbLinha  
        cQuery += " AND CNE_ITEMCT <> ' ' "+QbLinha  
        cQuery += " AND CNE_CLVL <> ' ' "+QbLinha  
    EndIf 

    cQuery += " AND CNE_QUANT > 0 "+QbLinha 
	
	MemoWrite("C:/ricardo/ValidaGrupoAprovacao_CNE.sql",cQuery)			     
    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasCNE,.F.,.T.)
            
    DbSelectArea(cAliasCNE)
    (cAliasCNE)->(DbGoTop())
    Count To nQtdReg
    (cAliasCNE)->(DbGoTop())
            
    If nQtdReg > 0
		xCusto := Alltrim((cAliasCNE)->CNE_CC)
        xItemC := Alltrim((cAliasCNE)->CNE_ITEMCT)
        xClass := Alltrim((cAliasCNE)->CNE_CLVL)
    Else 
        aDadosCNZ := GetDadosCNZ(xFil,xNumCtr,xRevCtr,xNumMed)
        If Len(aDadosCNZ) > 0
            xCusto := aDadosCNZ[1]
            xItemC := aDadosCNZ[2]
            xClass := aDadosCNZ[3]
        EndIf
	EndIf  
    (cAliasCNE)->(DbCloseArea())
Return {xCusto,xItemC,xClass}

/*/{Protheus.doc} GetDadosCNZ
Busca dos dados para quando existir rateio.
@type function 
@author Ricardo Tavares Ferreira
@version 12.1.27
@return array, Array com os dados da entidade contabil.
@since 13/04/2022
@history 13/04/2022, Ricardo Tavares Ferreira, Constru��o Inicial.
/*/
//=============================================================================================================================
    Static Function GetDadosCNZ(xFil,xNumCtr,xRevCtr,xNumMed)
//=============================================================================================================================

    Local xCusto      := ""
    Local xItemC      := ""
    Local xClass      := ""
	Local QbLinha		:= chr(13)+chr(10)
	Local cAliasCNZ	:= GetNextAlias()
	Local cQuery		:= ""
	Local nQtdReg  	:= 0

    cQuery := " SELECT TOP 1 "+QbLinha  
    cQuery += " CNZ_FILIAL "+QbLinha 
    cQuery += " , CNZ_CONTRA "+QbLinha 
    cQuery += " , CNZ_NUMMED "+QbLinha 
    cQuery += " , CNZ_REVISA "+QbLinha 

    If Alltrim(CN9->CN9_XGLOBA) == "N" .and. Alltrim(CND->CND_XEMPRE)+Alltrim(CND->CND_XFILIA) <> Alltrim(cEmpAnt)+Alltrim(CND->CND_FILIAL)
        cQuery += " ,CNZ_XCC CNZ_CC "+QbLinha  
        cQuery += " ,CNZ_XITEM CNZ_ITEMCT "+QbLinha  
        cQuery += " ,CNZ_XCLVL CNZ_CLVL "+QbLinha 
    Else
        cQuery += " ,CNZ_CC "+QbLinha  
        cQuery += " ,CNZ_ITEMCT "+QbLinha  
        cQuery += " ,CNZ_CLVL "+QbLinha  
    EndIf
   
    cQuery += " FROM "+QbLinha 
    cQuery +=   RetSqlName("CNZ") + " CNZ "+QbLinha
    cQuery += " WHERE "+QbLinha  
    cQuery += " CNZ.D_E_L_E_T_ = ' ' "+QbLinha  
    cQuery += " AND CNZ_CONTRA = '"+xNumCtr+"' "+QbLinha 
    cQuery += " AND CNZ_NUMMED = '"+xNumMed+"' "+QbLinha 
    cQuery += " AND CNZ_REVISA = '"+xRevCtr+"' "+QbLinha 
    cQuery += " AND CNZ_FILIAL = '"+xFil+"' "+QbLinha 

    If Alltrim(CN9->CN9_XGLOBA) == "N" .and. Alltrim(CND->CND_XEMPRE)+Alltrim(CND->CND_XFILIA) <> Alltrim(cEmpAnt)+Alltrim(CND->CND_FILIAL)
        cQuery += " AND CNZ_XCC <> ' ' "+QbLinha  
        cQuery += " AND CNZ_XITEM <> ' ' "+QbLinha  
        cQuery += " AND CNZ_XCLVL <> ' ' "+QbLinha 
    Else
        cQuery += " AND CNZ_CC <> ' ' "+QbLinha  
        cQuery += " AND CNZ_ITEMCT <> ' ' "+QbLinha  
        cQuery += " AND CNZ_CLVL <> ' ' "+QbLinha  
    EndIf
	
	MemoWrite("C:/ricardo/ValidaGrupoAprovacao_CNZ.sql",cQuery)			     
    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasCNZ,.F.,.T.)
            
    DbSelectArea(cAliasCNZ)
    (cAliasCNZ)->(DbGoTop())
    Count To nQtdReg
    (cAliasCNZ)->(DbGoTop())
            
    If nQtdReg > 0
		xCusto := Alltrim((cAliasCNZ)->CNZ_CC)
        xItemC := Alltrim((cAliasCNZ)->CNZ_ITEMCT)
        xClass := Alltrim((cAliasCNZ)->CNZ_CLVL)
	EndIf  
    (cAliasCNZ)->(DbCloseArea())
Return {xCusto,xItemC,xClass}
