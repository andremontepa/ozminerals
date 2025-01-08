#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PRTOPDEF.CH"

/*/{Protheus.doc} OZ02M002
Rotina de importação de Dados de Tabelas Pre Definidas
@type function           
@author Ricardo Tavares Ferreira
@since 10/03/2022
@version 12.1.27
@history 10/03/2022, Ricardo Tavares Ferreira, Construção Inicial
@return object, Retorna o objeto do Browse.
/*/
//=============================================================================================================================
    User Function OZ02M002()
//=============================================================================================================================

    Local lConfirm  := .F.
    Private oSay    := Nil 
    Private QbLinha	:= chr(13)+chr(10)

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
        FWMsgRun(,{|oSay| PutRegistros(oSay)},"Importação de Registros","Importando os Dados Selecionados...") 
    EndIf 
Return Nil

/*/{Protheus.doc} PutRegistros
Função que prepara os dados em array para ser incluidos
@type class 
@author Ricardo Tavares Ferreira
@since 10/03/2022
@version 12.1.27
@history 10/03/2022, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Static Function PutRegistros(oSay)
//=============================================================================================================================

    Local oFile     := Nil 
    Local nLin      := 1
    Local aLinhas   := {}
    Local aCampos   := {}
    Local aDados    := {}
    Local cTab      := ""

    If MV_PAR01 == 1 
        cTab := "SAL"
    Else
        cTab := "DBL"
    EndIf 

    oFile := FWFileReader():New(Alltrim(MV_PAR02))
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
        ExecIncl(aCampos,aLinhas,cTab)
    EndIf 

    oFile:Close()
Return Nil 

/*/{Protheus.doc} ExecIncl
Executa a inclusão
@type function
@author Ricardo Tavares Ferreira
@since 10/03/2022
@version 12.1.27
@history 10/03/2022, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
	Static Function ExecIncl(aCampos,aLinhas,cTab)
//====================================================================================================

    Local nX    := 0
    Local nY    := 0
    Local cUsr  := ""

    If cTab == "SAL"
        DbSelectArea("SAL")
        SAL->(DbSetOrder(1))
        For nX := 1 To Len(aLinhas)
            cUsr := GetUsrApr(aLinhas[nX][4])
            If .not. ExistSAL(Alltrim(aLinhas[nX][1]),Alltrim(aLinhas[nX][4]))
                RecLock("SAL",.T.)
                    SAL->AL_FILIAL  := FWXFilial("SAL")
                    For nY := 1 To Len(aLinhas[nX])
                        &(cTab+"->"+aCampos[nY]) := Iif(Alltrim(aLinhas[nX][nY]) == "T",.T.,Iif(Alltrim(aLinhas[nX][nY]) == "F",.F.,Alltrim(aLinhas[nX][nY])))
                    Next nY 
                    SAL->AL_USER    := cUsr
                    SAL->AL_AUTOLIM := "S"
                    SAL->AL_TPLIBER := "U"
                SAL->(MsUnlock())
            EndIf 
        Next nX 
    Else 
        DbSelectArea("DBL")
        DBL->(DbSetOrder(1))

        For nX := 1 To Len(aLinhas)
            If .not. ExistDBL(Alltrim(aLinhas[nX][1]),Alltrim(aLinhas[nX][2]),Alltrim(aLinhas[nX][3]),Alltrim(aLinhas[nX][4]),Alltrim(aLinhas[nX][5]))
                RecLock("DBL",.T.)
                    DBL->DBL_FILIAL := FWXFilial("DBL")
                    For nY := 1 To Len(aLinhas[nX])
                        &(cTab+"->"+aCampos[nY]) := Iif(Alltrim(aLinhas[nX][nY]) == "T",.T.,Iif(Alltrim(aLinhas[nX][nY]) == "F",.F.,Alltrim(aLinhas[nX][nY])))
                    Next nY 
                DBL->(MsUnlock())
            EndIf
        Next nX
    EndIf 
Return Nil

/*/{Protheus.doc} ExistDBL
Verifica se o arquivo DBL existe
@type function
@author Ricardo Tavares Ferreira
@since 12/03/2022
@version 12.1.27
@return character, Retorna o usuario da liberação.
@history 12/03/2022, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
	Static Function ExistDBL(cCod,cItem,cCusto,cItCont,cClasse)
//====================================================================================================

    Local QbLinha   := chr(13)+chr(10)
    Local cAliasDBL := GetNextAlias()
    Local cQuery   	:= ""
    Local nQtdReg   := 0

    cQuery := "SELECT * "+QbLinha
    cQuery += "FROM "
    cQuery +=  RetSqlName("DBL") + " DBL "+QbLinha
    cQuery += "WHERE "+QbLinha 
    cQuery += "DBL_FILIAL = '"+FWXFilial("DBL")+"' "+QbLinha
    cQuery += "AND DBL_GRUPO = '"+cCod+"' "+QbLinha 
    cQuery += "AND DBL_ITEM = '"+cItem+"' "+QbLinha 
    cQuery += "AND DBL_CC = '"+cCusto+"' "+QbLinha 
    cQuery += "AND DBL_ITEMCT = '"+cItCont+"' "+QbLinha 
    cQuery += "AND DBL_CLVL = '"+cClasse+"' "+QbLinha 

    MemoWrite("C:/ricardo/OZ02M002_ExistDBL.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDBL,.F.,.T.)
		
	DbSelectArea(cAliasDBL)
	(cAliasDBL)->(DbGoTop())
	Count To nQtdReg
	(cAliasDBL)->(DbGoTop())
		
	If nQtdReg > 0
        Return .T.
    EndIf 
    (cAliasDBL)->(DbCloseArea())
Return .F.

/*/{Protheus.doc} ExistSAL
Verifica se o grupo de aprovação existe
@type function
@author Ricardo Tavares Ferreira
@since 12/03/2022
@version 12.1.27
@return character, Retorna o usuario da liberação.
@history 12/03/2022, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
	Static Function ExistSAL(cCod,cAprov)
//====================================================================================================

    Local QbLinha   := chr(13)+chr(10)
    Local cAliasSAL := GetNextAlias()
    Local cQuery   	:= ""
    Local nQtdReg   := 0

    cQuery := "SELECT * "+QbLinha
    cQuery += "FROM "
    cQuery +=   RetSqlName("SAL") + " SAL "+QbLinha
    cQuery += "WHERE "+QbLinha 
    cQuery += "SAL.D_E_L_E_T_ = ' ' "+QbLinha
    cQuery += "AND AL_FILIAL = '"+FWXFilial("SAL")+"' "+QbLinha 
    cQuery += "AND AL_COD = '"+cCod+"' "+QbLinha 
    cQuery += "AND AL_APROV = '"+cAprov+"' "+QbLinha 
    cQuery += "ORDER BY AL_COD, AL_ITEM "+QbLinha

    MemoWrite("C:/ricardo/OZ02M002_ExistSAL.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSAL,.F.,.T.)
		
	DbSelectArea(cAliasSAL)
	(cAliasSAL)->(DbGoTop())
	Count To nQtdReg
	(cAliasSAL)->(DbGoTop())
		
	If nQtdReg > 0
        Return .T.
    EndIf 
    (cAliasSAL)->(DbCloseArea())
Return .F. 

/*/{Protheus.doc} GetUsrApr
Busca o Usuario de Aprovação
@type function
@author Ricardo Tavares Ferreira
@since 11/03/2022
@version 12.1.27
@return character, Retorna o usuario da liberação.
@history 11/03/2022, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
	Static Function GetUsrApr(cUsrLib)
//====================================================================================================
    
    Local cUsrProt  := ""
    Local QbLinha   := chr(13)+chr(10)
    Local cAliasSAK := GetNextAlias()
    Local cQuery   	:= ""
    Local nQtdReg   := 0

    cQuery := "SELECT AK_USER "+QbLinha
    cQuery += "FROM "
    cQuery +=   RetSqlName("SAK") + " SAK "+QbLinha
    cQuery += "WHERE "+QbLinha 
    cQuery += "SAK.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += "AND AK_FILIAL = '"+FWXFilial("SAK")+"' "+QbLinha
    cQuery += "AND AK_COD = '"+cUsrLib+"' "+QbLinha

    MemoWrite("C:/ricardo/OZ02M002_GetUsrApr.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSAK,.F.,.T.)
		
	DbSelectArea(cAliasSAK)
	(cAliasSAK)->(DbGoTop())
	Count TO nQtdReg
	(cAliasSAK)->(DbGoTop())
		
	If nQtdReg > 0
        cUsrProt := Alltrim((cAliasSAK)->AK_USER)
    EndIf 
    (cAliasSAK)->(DbCloseArea())
Return cUsrProt

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

 	aadd(aPergs,{3,"Tipo da Importação"			,1              ,{"SAL","DBL"}                		,65,"",.T.,}) //MV_PAR01
    aadd(aPergs,{6,"Local do Arquivo",Padr("",300),"",".T.","",80,.T.,""/*"Arquivos CSV |*.csv"*/,"",GETF_LOCALHARD+GETF_NETWORKDRIVE}) // MV_PAR02

	If .not. ParamBox(aPergs,"Buscar Arquivo",aRet,/*bValid*/,/*aButtons*/,.T.,/*nPosX*/,/*nPosY*/,/*oDialog*/,"RT69M002",.T.,.T.)
		lRet := .F.
	EndIf 
Return lRet
