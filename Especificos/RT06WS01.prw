#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

PUBLISH USER MODEL REST NAME Pagamentos RESOURCE OBJECT oRestSE2

/*/{Protheus.doc} oRestSE2
WebService da Rotina de Contas a Pagar
@author     Ricardo Tavares Ferreira
@since      11/08/2019
@version    12.1.17
@return     Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    Class oRestSE2 From AVBServices
//====================================================================================================

	Data oModelJson
    Data cIdUser
    Data cErrorMes
    Data cIdService
    Method Activate()
    Method GetDef()
    Method SetFilter()
    Method SaveData()
    Method SaveDataPortal()
    
EndClass

/*/{Protheus.doc} Activate
Metodo de Ativação da Classe
@author     Ricardo Tavares Ferreira
@since      11/08/2019
@version    12.1.17
@return     Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    Method Activate(cOperation) Class oRestSE2
//====================================================================================================
    self:oModelJson := JSONUTIL():New()
	self:cIdService := "oRestSE2"
	self:cIdUser    := __cuserId   
    self:cErrorMes  := ""
Return _Super:Activate() //Activate FWRestModelObject

/*/{Protheus.doc} GetDef
Metodo que busca os campos obrigatiorios para retornar no Json
@author     Ricardo Tavares Ferreira
@since      11/08/2019
@version    12.1.17
@return     Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    Method GetDef(cReturnPai) Class oRestSE2
//====================================================================================================

    Local cRetJson 	:= ""
	Local cFieldSE2	:= "E2_FILIAL|E2_PREFIXO|E2_NUM|E2_PARCELA|E2_TIPO|E2_NATUREZ|E2_FORNECE|E2_LOJA|E2_NOMFOR|E2_EMISSAO|E2_EMIS1|E2_VENCTO|E2_VENCREA|E2_HIST|E2_VALOR|E2_ITEMD|E2_CCUSTO"
    
    If ::oModelJson:FillProperty(cReturnPai,cFieldSE2,"SE2",Nil,"",,,.T.)
        cRetJson := ::oModelJson:cResult
    EndIf 
Return cRetJson 

/*/{Protheus.doc} SaveData
Metodo responsavel por gravar as informações no sistemas advindas dos metodos POST, PUT e DELETE
@author     Ricardo Tavares Ferreira
@since      11/08/2019
@version    12.1.17
@return     Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    Method SaveData(cPK,cData,cError) Class oRestSE2
//====================================================================================================
   
    Local lRet          := .F.
    Local oObj          := Nil
    Local aTitulos      := {}
    Local nX            := 0
    Local cFilAt        := cFilant  
    Local nOption       := 0  
    Private lMsErroAuto := .F.

    Default cData       := ""
    Default cPk         := ""
    Default cError      := ""
    
    If Empty(cPk)        
        self:cOperation := "POST"
        lRet := .T. // primeiro POST necessario até o momento
    Else   
        //self:oModel:SetOperation(MODEL_OPERATION_UPDATE)
        If self:Seek(cPK)
            lRet := .T.
        Else
            cError := "Chave nao encontrada verifique PK enviada"
        EndIf
        self:cOperation := "PUT"

    EndIf
    If lRet 
        lRet := ::ValidaExecucao() 
        If lRet 
            If FWJsonDeserialize(cData,@oObj)
                cFilant := oObj:RESOURCES[1]:filial
                For nX := 1 To Len(oObj:RESOURCES)
                
                    aadd( aTitulos , { "E2_FILIAL"  , oObj:RESOURCES[nX]:FILIAL             , Nil })
                    aadd( aTitulos , { "E2_PREFIXO" , oObj:RESOURCES[nX]:PREFIXO            , Nil })
                    aadd( aTitulos , { "E2_NUM"     , oObj:RESOURCES[nX]:NOTITULO           , Nil })
                    aadd( aTitulos , { "E2_PARCELA" , oObj:RESOURCES[nX]:PARCELA            , Nil })
                    aadd( aTitulos , { "E2_TIPO"    , oObj:RESOURCES[nX]:TIPO               , Nil })
                    aadd( aTitulos , { "E2_NATUREZ" , oObj:RESOURCES[nX]:NATUREZA           , Nil })
                    aadd( aTitulos , { "E2_FORNECE" , oObj:RESOURCES[nX]:FORNECEDOR         , Nil })
                    aadd( aTitulos , { "E2_LOJA"    , oObj:RESOURCES[nX]:LOJA               , Nil })
                    aadd( aTitulos , { "E2_NOMFOR"  , oObj:RESOURCES[nX]:NOMEFORNECE        , Nil })
                    aadd( aTitulos , { "E2_EMISSAO" , Ctod(oObj:RESOURCES[nX]:DTEMISSAO)    , Nil })
                    aadd( aTitulos , { "E2_EMIS1"   , Ctod(oObj:RESOURCES[nX]:DTCONTAB)     , Nil })
                    aadd( aTitulos , { "E2_VENCTO"  , Ctod(oObj:RESOURCES[nX]:VENCIMENTO)   , Nil })
                    aadd( aTitulos , { "E2_VENCREA" , Ctod(oObj:RESOURCES[nX]:VENCTOREAL)   , Nil })
                    aadd( aTitulos , { "E2_HIST"    , oObj:RESOURCES[nX]:HISTORICO          , Nil })
                    aadd( aTitulos , { "E2_VALOR"   , Val(oObj:RESOURCES[nX]:VLRTITULO)     , Nil }) 
                    aadd( aTitulos , { "E2_ITEMD"   , oObj:RESOURCES[nX]:ITEMCTBDEB         , Nil })        
                    aadd( aTitulos , { "E2_CCUSTO"  , oObj:RESOURCES[nX]:CDECUSTO           , Nil })

                    If Alltrim(::cOperation) == "POST"
                        nOption := 3
                    ElseIf Alltrim(::cOperation) == "PUT"
                        nOption := 4
                    ElseIf Alltrim(::cOperation) == "DELETE"
                        nOption := 5
                    EndIf

                    MsExecAuto({|x,y,z| FINA050(x,y,z)},aTitulos,,nOption)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
                    
                    If lMsErroAuto
                        cError :=  MostraErro()
                        lRet := .F.                   
                    Else
                    
                    Endif
                Next nX
            EndIf
        EndIf
    EndIF
    cFilant := cFilAt
return lRet

/*/{Protheus.doc} SetFilter
Metodo responsavel por realizar filtros de informação caso necessario
@author     Ricardo Tavares Ferreira
@since      11/08/2019
@version    12.1.17
@return     Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    Method SetFilter(cFilter) Class oRestSE2
//==================================================================================================== 
    lRet := _Super:SetFilter(cFilter)
Return lRet

/*/{Protheus.doc} RT06WS01
Rotina responsavel por criar a WebService de Contas a Pagar 
@author     Ricardo Tavares Ferreira
@since      05/06/2019
@version    12.1.17
@return     Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    User Function RT06WS01()
//====================================================================================================
    Local cIdService := "oRestSE2"
	Local cIdUser    := __cuserId   
Return Nil

/*/{Protheus.doc} ModelDef
Rotina responsavel por criar o modelo de Dados do Pedido de Venda
@author     Ricardo Tavares Ferreira
@since      05/06/2019
@version    12.1.17
@return     Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    Static Function ModelDef()
//====================================================================================================

    Local oModel    	:= Nil
    Local oStrSE2     	:= Nil
    Local aCampos   	:= {}
    Local cFieldSE2  	:= ""
    Local nX        	:= 0

    DbSelectArea("SE2")

    aCampos := SE2->(DbStruct())
	
	For nX := 1 To Len(aCampos)
		cFieldSE2 += aCampos[nX][1]
		cFieldSE2 += Iif((nX) < Len(aCampos),"|","")
	Next

    // Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("SE2MOD",{|| PreValida(oModel)},{|oModel| PosValida(oModel)},{|oModel|,fCommit(oModel)},{|oModel|,fCancel(oModel)}) // Cria o objeto do Modelo de Dados

    // Cria o Objeto da Estrutura dos Campos da tabela
	oStrSE2 := FWFormStruct(1,"SE2",{|cCampo| ( Alltrim(cCampo) $ cFieldSE2 )})

    // Adiciona ao modelo um componente de formulario
	oModel:AddFields("M_SE2",/*cOwner*/,oStrSE2) 

    // Seta a chave primaria que sera utilizada na gravacao dos dados na tabela 
	oModel:SetPrimaryKey({"E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO","E2_FORNECE","E2_LOJA"})
    
Return oModel