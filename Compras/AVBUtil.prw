#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "fileio.ch"

/*/{Protheus.doc} AVBUtil
Fonte contendo todas os metodos e classes genericos.
@type class 
@author Ricardo Tavares Ferreira
@since 11/10/2021
@version 12.1.27
@history 11/10/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Class AVBUtil from LongNameClass
//=============================================================================================================================

	Static Method TrocaGrupoAprovacao(cTabela,cNum,cClasse,dData,nTotal)
	Static Method ValidaGrupoAprovacao(cTabela,xCentroCusto,xItemContabil,xClasseValor)
	Static Method DeletaGrupoAprovacao(xFil,cNum,cTipo)
	Static Method GetSM2(cDtTaxa)
    
EndClass

/*/{Protheus.doc} GetSM2
Valida se existe a Taxa de Moeda cadastrada conforme a data passada.
@type function 
@author Ricardo Tavares Ferreira
@since 07/05/2022
@version 12.1.33
@history 07/05/2022, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Method GetSM2(cDtTaxa) class AVBUtil
//=============================================================================================================================

	Local QbLinha	:= chr(13)+chr(10)
	Local cAliasSM2	:= GetNextAlias()
	Local cQuery	:= ""
    Local lExiste   := .T.

    cQuery := " SELECT SM2.* "+QbLinha 
	cQuery += " FROM "
	cQuery +=   RetSqlName("SM2") + " SM2 "+QbLinha 
    cQuery += " WHERE SM2.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += " AND M2_DATA = '"+cDtTaxa+"' "+QbLinha 
    cQuery += " AND M2_MOEDA2 <> 0 "+QbLinha

    MemoWrite("C:/ricardo/FA080TIT_GetSM2.sql",cQuery)			     
    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSM2,.F.,.T.)
            
    DbSelectArea(cAliasSM2)
    (cAliasSM2)->(DbGoTop())
    Count To nQtdReg
    (cAliasSM2)->(DbGoTop())
            
    If nQtdReg <= 0
        lExiste := .F.
	EndIf  
    (cAliasSM2)->(DbCloseArea())
Return lExiste

/*/{Protheus.doc} DeletaGrupoAprovacao
Metodo responsável por deletar dados da tabela SCR.
@type Method
@author Ricardo Tavares Ferreira
@since 11/10/2021
@history 11/10/2021, Ricardo Tavares Ferreira , Construção Inicial.
/*/
//===============================================================================================================
    Method DeletaGrupoAprovacao(xFil,cNum,cTipo) class AVBUtil
//===============================================================================================================

	Local cDelete := ""
	Local QbLinha := chr(13)+chr(10)

	cDelete := " DELETE FROM " +RetSqlName("SCR")
	cDelete += " WHERE CR_FILIAL = '"+xFil+"'  "+QbLinha
	cDelete += " AND   CR_NUM	= '"+cNum+"' "+QbLinha
	cDelete += " AND   CR_TIPO	= '"+cTipo+"' "+QbLinha

	If TCSQLExec(cDelete) < 0
        Conout("Erro ao Deletar os Dados da Tabela SCR " + TCSQLError())
    EndIf 
 
Return Nil 

/*/{Protheus.doc} ValidaGrupoAprovacao
Metodo responsável por verificar se a amarração contabil existe e se tem o Grupo de Aprovação.
@type Method
@author Ricardo Tavares Ferreira
@since 11/10/2021
@history 11/10/2021, Ricardo Tavares Ferreira , Construção Inicial.
/*/
//===============================================================================================================
    Method ValidaGrupoAprovacao(cTabela,xCentroCusto,xItemContabil,xClasseValor) class AVBUtil
//===============================================================================================================
	
	Local cGrupoAprov 		:= ""
	Local QbLinha			:= chr(13)+chr(10)
	Local cAliasDBL			:= GetNextAlias()
	Local cAliasSAL			:= GetNextAlias()
	Local cQuery			:= ""
	Local nQtdDBL  			:= 0
	Local nQtdSAL  			:= 0
	Local cTpDBL      		:= Alltrim( SuperGetMV("OZ_TPDBL",,"C"))
	Local lRet				:= .T. 
	
	Default cTabela	 		:= ""
	Default xCentroCusto	:= ""
	Default xItemContabil	:= ""
	Default xClasseValor	:= ""
	
	cQuery := " SELECT DBL_GRUPO "+QbLinha
	cQuery += " FROM "
	cQuery +=   RetSqlName("DBL") + " DBL "+QbLinha 
	cQuery += " WHERE "+QbLinha
	cQuery += " DBL_FILIAL = '"+FWXFilial("DBL")+"'"+QbLinha 
	cQuery += " AND DBL_CC = '"+xCentroCusto+"'"+QbLinha 
	cQuery += " AND DBL_ITEMCT = '"+xItemContabil+"'"+QbLinha 
	cQuery += " AND DBL_CLVL = '"+xClasseValor+"'"+QbLinha 
	cQuery += " AND DBL_GRUPO NOT LIKE '%MD%' "+QbLinha
	cQuery += " AND DBL_XTIPO = '"+cTpDBL+"'"+QbLinha
	cQuery += " AND DBL.D_E_L_E_T_ = ' '"+QbLinha
	
	MemoWrite("C:/ricardo/ValidaGrupoAprovacao_DBL.sql",cQuery)			     
    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDBL,.F.,.T.)
            
    DbSelectArea(cAliasDBL)
    (cAliasDBL)->(DbGoTop())
    Count To nQtdDBL
    (cAliasDBL)->(DbGoTop())
            
    If nQtdDBL <= 0
		(cAliasDBL)->(DbCloseArea())
	Else 
		While .not. (cAliasDBL)->(Eof())
			cQuery := " SELECT AL_COD "+QbLinha 
			cQuery += " FROM "
			cQuery +=   RetSqlName("SAL") + " SAL "+QbLinha
			cQuery += " WHERE "+QbLinha 
			cQuery += " SAL.D_E_L_E_T_ = ' ' "+QbLinha 
			cQuery += " AND AL_COD = '"+Alltrim((cAliasDBL)->DBL_GRUPO)+"' "+QbLinha 
			
			If cTabela == "SC1" 
				cQuery += " AND AL_DOCSC = 'T' "+QbLinha
			ElseIf  cTabela == "CN9"
				cQuery += " AND AL_DOCMD = 'T' "+QbLinha
			ElseIf cTabela == "SC7"
				cQuery += " AND AL_DOCPC = 'T' "+QbLinha
			ElseIf cTabela == "SCP"
				cQuery += " AND AL_DOCSA = 'T' "+QbLinha
			EndIf 
			
			MemoWrite("C:/ricardo/ValidaGrupoAprovacao_SAL.sql",cQuery)			     
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSAL,.F.,.T.)
					
			DbSelectArea(cAliasSAL)
			(cAliasSAL)->(DbGoTop())
			Count To nQtdSAL
			(cAliasSAL)->(DbGoTop())
					
			If nQtdSAL <= 0
				(cAliasSAL)->(DbCloseArea())
			Else 
				cGrupoAprov := Alltrim((cAliasSAL)->AL_COD)
				Exit
			EndIf 
			(cAliasDBL)->(DbSkip())
		End
		(cAliasDBL)->(DbCloseArea())
	EndIf 

	If Empty(Alltrim(cGrupoAprov))
		lRet := .F. 
	EndIf 
Return {lRet,cGrupoAprov}

/*/{Protheus.doc} TrocaGrupoAprovacao
Metodo responsável por Trocar o Grupo de Aprovação caso nao encontre preenchido na tabela.
@type Method
@author Ricardo Tavares Ferreira
@since 11/10/2021
@history 11/10/2021, Ricardo Tavares Ferreira , Construção Inicial.
/*/
//===============================================================================================================
    Method TrocaGrupoAprovacao(cTabela,cNum,cClasse,dData,nTotal,cGrpAprov,cRev) class AVBUtil
//===============================================================================================================

    Local cUpd      	:= ""
    Local QbLinha		:= chr(13)+chr(10)
    Local cCodGrupo 	:= ""
	Local cTpDoc		:= ""
    Local cGRPPad   	:= Alltrim(SuperGetMV("OZ_GRPAD",,"AVB990"))
    Default cTabela 	:= ""
    Default cNum    	:= ""
    Default cClasse 	:= ""
    Default nTotal  	:= 1
    Default dData   	:= dDataBase
	Default cGrpAprov 	:= ""
	Default cRev        := ""
    
    /*If .not. Empty(cClasse)
        If cClasse == "OPX"
            cCodGrupo := SuperGetMV("MV_GRUPOPX",.F.,"AVB990")
        ElseIf cClasse == "CPX"
            cCodGrupo := SuperGetMV("MV_GRUPCPX",.F.,"AVB991")
        EndIf
    Else 
        cCodGrupo := "AVB990"
    EndIf*/

	If Empty(cGrpAprov)
    	cCodGrupo := cGRPPad
	Else 
		cCodGrupo := cGrpAprov
	EndIf 
    
    If cTabela == "SC1"
        cUpd := " UPDATE "+RetSqlName("SC1") +QbLinha
        cUpd += " SET C1_APROV = 'B' "+QbLinha
        cUpd += " WHERE "+QbLinha
        cUpd += " D_E_L_E_T_ = ' ' "+QbLinha 
        cUpd += " AND C1_FILIAL = '"+FWXFilial("SC1")+"' "+QbLinha
        cUpd += " AND C1_NUM = '"+cNum+"' "+QbLinha

    	//maAlcDoc({cNum,"SC",nTotal,,,cCodGrupo,,1,1,dData},,1)
		U_MaAlcDocL({cNum,"SC",nTotal,,,cCodGrupo,,1,1,dData},dData,1,"",.F.)
    ElseIf cTabela == "SC7"
        cUpd := " UPDATE "+RetSqlName("SC7") +QbLinha
        cUpd += " SET C7_APROV = '"+cCodGrupo+"', C7_CONAPRO = 'B' "+QbLinha
        cUpd += " WHERE "+QbLinha
        cUpd += " D_E_L_E_T_ = ' ' "+QbLinha 
        cUpd += " AND C7_FILIAL = '"+FWXFilial("SC7")+"' "+QbLinha
        cUpd += " AND C7_NUM = '"+cNum+"' "+QbLinha

        //maAlcDoc({cNum,"PC",nTotal,,,cCodGrupo,,1,1,dData},,1)
		U_MaAlcDocL({cNum,"PC",nTotal,,,cCodGrupo,,1,1,dData},dData,1,"",.F.)
    ElseIf cTabela == "CN9"
        cUpd := " UPDATE "+RetSqlName("CN9") +QbLinha
        cUpd += " SET CN9_APROV = '"+cCodGrupo+"', CN9_XAPROV = '"+cCodGrupo+"' "+QbLinha
        cUpd += " WHERE "+QbLinha
        cUpd += " D_E_L_E_T_ = ' ' "+QbLinha 
        cUpd += " AND CN9_FILIAL = '"+FWXFilial("CN9")+"' "+QbLinha
        cUpd += " AND CN9_NUMERO = '"+cNum+"' "+QbLinha
		cUpd += " AND CN9_REVISA = '"+cRev+"' "+QbLinha
		IF Empty(cRev)
			cTpDoc := "CT"
		else
			cTpDoc := "RV"
		ENDIF
		//If cTpDoc == "CT"
			//maAlcDoc({cNum+cRev,cTpDoc,nTotal,,,cCodGrupo,,1,1,dData},,1)
			U_MaAlcDocL({cNum+cRev,cTpDoc,nTotal,,,cCodGrupo,,1,1,dData},dData,1,"",.F.)
		//EndIf
	ElseIf cTabela == "SCP"
        //cUpd := " UPDATE "+RetSqlName("SCP") +QbLinha
        //cUpd += " SET CP_XAPROV = '"+cCodGrupo+"' "+QbLinha
        //cUpd += " WHERE "+QbLinha
        //cUpd += " D_E_L_E_T_ = ' ' "+QbLinha 
        //cUpd += " AND CP_FILIAL = '"+FWXFilial("SCP")+"' "+QbLinha
        //cUpd += " AND CP_NUM = '"+cNum+"' "+QbLinha
//
        //maAlcDoc({cNum,"SA",nTotal,,,cCodGrupo,,1,1,dData},,1)
    EndIf 

	If TcSqlExec(cUpd) < 0
		Conout("[AVBUtil] [TrocaGrupoAprovacao]  [" + Dtoc(DATE()) +" "+ Time()+ "]  Falha da Execução do UPDATE - Tabela ("+cTabela+") ...")
	Else
		Conout("[AVBUtil] [TrocaGrupoAprovacao]  [" + Dtoc(DATE()) +" "+ Time()+ "]  Update na Tabela "+cTabela+" executado com sucesso ...")
	EndIf
Return Nil 
