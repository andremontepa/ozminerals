#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWBROWSE.CH'

/*/{Protheus.doc} AVBServices
Classe responsável por criar a API de Integração da AVB Mineração.
@author Ricardo Tavares Ferreira
@since 10/08/2019
@version 12.1.17
@return Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    Class AVBServices From FwRestModel
//====================================================================================================

    Data cBranch
    Data cIdService
    Data cIdUSer
    Data cOperation
    Data cReturnMsg
    Data lCanExecute
    Data oQuery
    Data aValues
    
    Method Free() 
    Method Activate()
    Method DeActivate()
    Method UsrAcces(cIdService,cIdUser)
    Method ValidaExecucao(cIdService,cOperation) 
    Method GetData(lFieldDetail, lFieldVirtual, lFieldEmpty, lFirstLevel, lInternalID)
    Method GetDef()

End Class

/*/{Protheus.doc} Free
Classe responsável por resetar o objeto.
@author Ricardo Tavares Ferreira
@since 10/08/2019
@version 12.1.17
@return Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    Method Free() Class AVBServices
//====================================================================================================
    FWFreeObj(self)
Return Nil

/*/{Protheus.doc} UsrAcces
Classe responsável por validar se o usuario tem acesso para utilizar os metodos.
@author Ricardo Tavares Ferreira
@since 10/08/2019
@version 12.1.17
@return Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    Method UsrAcces(cIdService,cIdUser) Class AVBServices
//====================================================================================================

    Local lResult       := .F.
    Local lUser         := .T.
    Default cIdService  := ""
    Default cIdUser     := ""

    ::cReturnMsg :=  "Usuario sem Permissao"

    lUser := ValidaUser(cIdUser)

	If lUser 
        ::cReturnMsg    := "Acesso permitido"
        lResult         := .T.
        Return lResult
    EndIF
    SetRestFault(403,::cReturnMsg) 
Return lResult

/*/{Protheus.doc} ValidaExecucao
Classe responsável por validar se o Tipo de Execucao pode ser Executado.
@author Ricardo Tavares Ferreira
@since 10/08/2019
@version 12.1.17
@return Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    Method ValidaExecucao() Class AVBServices
//====================================================================================================

    Local lResult   := .F.
    Local lExecuta  := .T.
    
    ::cReturnMsg :=  "Metodo sem permissao para Execucao"

    lExecuta := ValidaOper(::cIdService,::cIdUSer,::cOperation)

    If lExecuta
        lResult := .T.
        ::cReturnMsg := 'Metodo permitido'
        Return lResult
    EndIf

    SetRestFault(405,::cReturnMsg) 
Return lResult

/*/{Protheus.doc} Activate
Classe responsável por Ativar a Classe.
@author Ricardo Tavares Ferreira
@since 10/08/2019
@version 12.1.17
@return Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    Method Activate(cOperation) Class AVBServices
//====================================================================================================
Return _Super:Activate() //Activate FWRestModelObject

/*/{Protheus.doc} DeActivate
Classe responsável por Desativar a Classe.
@author Ricardo Tavares Ferreira
@since 10/08/2019
@version 12.1.17
@return Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    Method DeActivate() Class AVBServices
//====================================================================================================
Return _Super:DeActivate() //DeActivate FWRestModelObject

/*/{Protheus.doc} ValidaUser
Funcao responsavel por verificar se o usuario tem permissao para utilizar a API
@author     Ricardo Tavares Ferreira
@since      11/08/2019
@version    12.1.17
@return     Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    Static Function ValidaUser(cIdUser)
//====================================================================================================

    Local cQuery	:= ""
	Local QbLinha	:= chr(13)+chr(10)
	Local nQtdReg	:= 0
    Local cAlias    := GetNextAlias()

    Default cIdUser := ""

    cQuery := " SELECT "+QbLinha 
    cQuery += " ZC_FILIAL FILIAL "+QbLinha
    cQuery += " , ZC_USER USER1 "+QbLinha
    cQuery += " , ZC_SERVICO SERVICO "+QbLinha
    cQuery += " , ZC_GET OPGET "+QbLinha
    cQuery += " , ZC_POST OPPOST "+QbLinha
    cQuery += " , ZC_PUT OPPUT "+QbLinha
    cQuery += " , ZC_DELETE OPDELETE "+QbLinha

    cQuery += " FROM "
    cQuery +=   RetSqlName("SZC") + " SZC "+QbLinha

    cQuery += " WHERE SZC.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += " AND ZC_USER = '"+cIdUser+"' "+QbLinha

    MEMOWRITE("C:/ricardo/ValidaUser_RT99WS01.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DBUSEAREA(.T.,'TOPCONN',TcGenQry(,,cQuery),cAlias,.F.,.T.)
		
	DBSELECTAREA(cAlias)
	(cAlias)->(DBGOTOP())
	Count To nQtdReg
	(cAlias)->(DBGOTOP())
		
	If nQtdReg <= 0
		(cAlias)->(DBCLOSEAREA())
        Return .F.
	EndIf
Return .T.

/*/{Protheus.doc} ValidaOper
Funcao responsavel por verificar se o usuario tem permissao para utilizar a API
@author     Ricardo Tavares Ferreira
@since      11/08/2019
@version    12.1.17
@return     Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    Static Function ValidaOper(cIdService,cIdUSer,cOperation)
//====================================================================================================

    Local cQuery	    := ""
	Local QbLinha	    := chr(13)+chr(10)
	Local nQtdReg	    := 0
    Local cAlias        := GetNextAlias()

    Default cIdUSer     := ""
    Default cIdService  := ""
    Default cOperation  := ""

    cQuery := " SELECT "+QbLinha 
    cQuery += " ZC_FILIAL FILIAL "+QbLinha
    cQuery += " , ZC_USER USER1 "+QbLinha
    cQuery += " , ZC_SERVICO SERVICO "+QbLinha
    cQuery += " , ZC_GET OPGET "+QbLinha
    cQuery += " , ZC_POST OPPOST "+QbLinha
    cQuery += " , ZC_PUT OPPUT "+QbLinha
    cQuery += " , ZC_DELETE OPDELETE "+QbLinha

    cQuery += " FROM "
    cQuery +=   RetSqlName("SZC") + " SZC "+QbLinha

    cQuery += " WHERE SZC.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += " AND ZC_USER = '"+cIdUser+"' "+QbLinha
    cQuery += " AND ZC_SERVICO = '"+cIdService+"' "+QbLinha

    Do Case
        case cOperation == "GET"
            cQuery += " AND ZC_GET = 'T' "+QbLinha            
        case cOperation == "POST"
            cQuery += " AND ZC_POST = 'T' "+QbLinha            
        case cOperation == "PUT"
            cQuery += " AND ZC_PUT = 'T' "+QbLinha            
        case cOperation == "DELETE"
            cQuery += " AND ZC_DELETE = 'T' "+QbLinha            
    EndCase

    MEMOWRITE("C:/ricardo/ValidaOper_RT99WS01.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DBUSEAREA(.T.,'TOPCONN',TcGenQry(,,cQuery),cAlias,.F.,.T.)
		
	DBSELECTAREA(cAlias)
	(cAlias)->(DBGOTOP())
	Count To nQtdReg
	(cAlias)->(DBGOTOP())
		
	If nQtdReg <= 0
		(cAlias)->(DBCLOSEAREA())
        Return .F.
	EndIf
Return .T.

/*/{Protheus.doc} ValidaOper
Funcao responsavel por verificar se o usuario tem permissao para utilizar a API
@author     Ricardo Tavares Ferreira
@since      11/08/2019
@version    12.1.17
@return     Nil
@obs Ricardo Tavares - Construcao Inicial
@param	lFieldDetail	Indica se retorna o registro com informações detalhadas
@param	lFieldVirtual	Indica se retorna o registro com campos virtuais
@param	lFieldEmpty 	Indica se retorna o registro com campos nao obrigatorios vazios
@param	lFirstLevel		Indica se deve retornar todos os modelos filhos ou nao
@param	lInternalID     Indica se deve retornar o ID como informação complementar das linhas do GRID 
/*/
//=============================================================================================================
    Method GetData(lFieldDetail, lFieldVirtual, lFieldEmpty, lFirstLevel, lInternalID) Class AVBServices
//=============================================================================================================

    Local xRet 

    ::cOperation := 'GET' //Deve ter algum atributo padrao para isso
    if ::ValidaExecucao(::cIdService,::cOperation) 
        if ::UsrAcces(::cIdService,::cIdUser)
            xRet := _Super:GetData(lFieldDetail, lFieldVirtual, lFieldEmpty, lFirstLevel, lInternalID) //GetData FWRestModelObject        
            if ValType(xRet) == 'C' // se lógico não pode ser executado
                return ::GetDef(xRet)
            EndIf
        EndIF
    EndIF
Return .F. 

/*/{Protheus.doc} ValidaOper
Funcao responsavel por verificar se o usuario tem permissao para utilizar a API
@author     Ricardo Tavares Ferreira
@since      11/08/2019
@version    12.1.17
@return     Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//=============================================================================================================
    method getDef(xRetPai) class AVBServices
//=============================================================================================================
Return xRetPai