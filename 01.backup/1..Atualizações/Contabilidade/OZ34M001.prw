#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PRTOPDEF.CH"

/*/{Protheus.doc} OZ34M001
Rotina de Alteração de Filial das contabilizações
@type function           
@author Ricardo Tavares Ferreira
@since 27/04/2022
@version 12.1.27
@history 27/04/2022, Ricardo Tavares Ferreira, Construção Inicial
@return object, Retorna o objeto do Browse.
/*/
//=============================================================================================================================
    User Function OZ34M001()
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
    //CtbStatus(cMoeda,dDataIni,dDataFim,lAll)
    //Valida Calendario contabil se esta aberto ou fechado
    If .not. CtbStatus("01",MV_PAR01,MV_PAR01,.T.)
        lConfirm := .F.
    EndIf  
    If lConfirm 
        FWMsgRun(,{|oSay| PutRegistros(oSay)},"Processamento de Lançamentos","Processando registros encontrados na data informada...") 
    EndIf 
Return Nil


/*/{Protheus.doc} PutRegistros
Função que prepara os dados em array para ser incluidos
@type function 
@author Ricardo Tavares Ferreira
@since 27/04/2022
@version 12.1.27
@history 27/04/2022, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Static Function PutRegistros(oSay)
//=============================================================================================================================

    Local QbLinha   := chr(13)+chr(10)
    Local cAliasCT2 := GetNextAlias()
    Local cQuery   	:= ""
    Local nQtdReg   := 0

    cQuery := "SELECT CT2.R_E_C_N_O_ IDCT2, CT2.* "+QbLinha
    cQuery += "FROM "
    cQuery +=  RetSqlName("CT2") + " CT2 "+QbLinha
    cQuery += "WHERE CT2.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += "AND CT2_LOTE = '008840' "+QbLinha
    cQuery += "AND CT2_DATA = '"+Dtos(MV_PAR01)+"' "+QbLinha

    If MV_PAR02 == 1 
        cQuery += "AND SUBSTRING(CT2_FILIAL,1,1) <> 'X' "+QbLinha
    Else
        cQuery += "AND SUBSTRING(CT2_FILIAL,1,1) = 'X' "+QbLinha
    EndIf


    MemoWrite("C:/ricardo/OZ34M001_PutRegistros.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCT2,.F.,.T.)
		
	DbSelectArea(cAliasCT2)
	(cAliasCT2)->(DbGoTop())
	Count TO nQtdReg
	(cAliasCT2)->(DbGoTop())
	
    DbselectArea("CT2")
    CT2->(DbSetOrder(1))

	If nQtdReg > 0
        While .not. (cAliasCT2)->(Eof())
            CT2->(DbGoTo((cAliasCT2)->IDCT2))
            RecLock("CT2", .F.)
                If MV_PAR02 == 1 
                    CT2->CT2_FILIAL := "X" + SubStr(Alltrim((cAliasCT2)->CT2_FILIAL),2,1)
                Else 
                    CT2->CT2_FILIAL := "0" + SubStr(Alltrim((cAliasCT2)->CT2_FILIAL),2,1)
                EndIf 
            CT2->(MsUnlock())
            (cAliasCT2)->(DBSkip()) 
        End
        MsgInfo("Suspensão Lote Custo Médio efetuado com Sucesso.","Atenção")
    Else
        MsgStop("Não foi encontrado nenhum registro com a data informada.","Atenção")   
    EndIf 
    (cAliasCT2)->(DbCloseArea())
Return Nil 

/*/{Protheus.doc} GetPerg
Criacao das Perguntas da Rotina tipo Parambox. 
@type function
@author Ricardo Tavares Ferreira
@since 27/04/2022
@version 12.1.27
@return logical, Retorna logico se confirmou os paramtros.
@history 27/04/2022, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
	Static Function GetPerg()
//====================================================================================================

    Local aPergs	    := {}
    Local aRet		    := {}
    Local lRet		    := .T.
    Local aTpExec       := {"Susp Lt Cust. Médio","Ret Lt Cust Médio"} 
    Private cCadastro   := "Perguntas"

 	aAdd(aPergs,{1,"Data do Lançamento" , DdataBase ,"","","","",50,.T.}) //MV_PAR01
    aadd(aPergs,{3,"Tipo de Execução"	, 1         ,aTpExec,65,"",.T.,}) //MV_PAR01
    //aadd(aPergs,{6,"Local do Arquivo",Padr("",300),"",".T.","",80,.T.,""/*"Arquivos CSV |*.csv"*/,"",GETF_LOCALHARD+GETF_NETWORKDRIVE}) // MV_PAR02

	If .not. ParamBox(aPergs,"Processamento de Lançamentos",aRet,/*bValid*/,/*aButtons*/,.T.,/*nPosX*/,/*nPosY*/,/*oDialog*/,"OZ34M001",.T.,.T.)
		lRet := .F.
	EndIf 
Return lRet
