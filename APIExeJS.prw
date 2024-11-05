#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} APIExeJS
Classe Responsavel por Buscar e Gerar os dados via Json.
@type class 
@author Ricardo Tavares Ferreira
@since 30/03/2021
@history 30/03/2021, Ricardo Tavares Ferreira, Construção Inicial
@history 03/04/2021, Ricardo Tavares Ferreira, Inclusão do Metodo que Valida a Operação executada.
@history 03/04/2021, Ricardo Tavares Ferreira, Inclusão do Metodo que processa as operações de POST/PUT/DELETE Tabela SC7.
@history 03/04/2021, Ricardo Tavares Ferreira, Inclusão do Metodo que monta o Json de Retorno após a execução da operação Tabela SC7.
@history 03/04/2021, Ricardo Tavares Ferreira, Inclusão do Metodo que monta o Array de Cabeçalho e Item para o ExecAuto Tabela SC7.
@history 04/04/2021, Ricardo Tavares Ferreira, Inclusão do Metodo que cria um modelo de dados da Tabela SC7.
@history 07/04/2021, Ricardo Tavares Ferreira, Inclusão do Metodo que Retorna o Json no Resultado das operações POST/PUT/DELETE.
@history 08/04/2021, Ricardo Tavares Ferreira, Tratamento no filtro pela PK do registro.
@history 09/04/2021, Ricardo Tavares Ferreira, Tratamento na Validação do Filtro passado no parametro da requisição.
@history 10/04/2021, Ricardo Tavares Ferreira, Tratamento para APIs que tem cabeçalho e Grid.
@history 10/04/2021, Ricardo Tavares Ferreira, Criação do Metodo responsavel por remover linhas duplicadas de um array multidimensional.
@history 10/04/2021, Ricardo Tavares Ferreira, Criação do Metodo responsavel por unir 2 Arrays.
@history 29/05/2021, Ricardo Tavares Ferreira, Busca os dados da Tabela SC7 para validar se o item existe.
@history 02/06/2021, Ricardo Tavares Ferreira, Realiza a exclusão dos dados da SCR na exclusão do pedido de compras.
/*/
//=============================================================================================================================
    Class APIExeJS From LongNameClass
//=============================================================================================================================
    
    Data cIdServ    as String 
    Data cIdUser    as String 
    Data nCode      as Integer
    Data cMsgRet    as String
    Data cItemServ  as String
    Data cOper      as String 
    Data cCompany   as String 
    Data cBranch    as String
    Data cPK        as String
    Data aTab       as Array

    Method DeletaSCR(xFil,xNum)
    Method GetRegSC7(cNum,cItem,cOper)
    Method UneArrays(aDadosCab,aDadosIte)
    Method RemoveDuplArray(aDados)
    Method ValidaFiltro(cFiltro)
    Method GetFiltroPK()
    Method GetJsonResult(lGrid,cInnerJoin,cFiltroRet)
    Method GetModelSC7()
    Method MontaArrayExecAutoSC7(cBody)
    Method ProcessaOperacaoSC7(cBody)
    Method SetRespSuce(nCod,cMsg)
    Method ValidaOperacao()
    Method TransformArraytoJson(aDados,cNameJs,nCount,StartIndex,lGrid,cCamposCab,cCamposGrid)
    Method GetCamposServ(cTab,cItemServ)
    Method GetJsonQuery(nCount,StartIndex,cNameJs,cFiltro,lGrid,cInnerJoin)
    Method SetRespError(nCode,cMsgRet)
    Method ValidaEmpresaFilial()
    Method ValidaUsuario()
    Method Valida()
    Method New(cIdServ,cItemServ,cIdUser,cOper,cCompany,cBranch,aTab) Constructor
EndClass

/*/{Protheus.doc} DeletaSCR
Metodo responsavel por excluir os dados da tabela SCR conforme parametros passados.
@type Method 
@author Ricardo Tavares Ferreira
@since 02/06/2021
@version 12.1.27
@return logical, Retorna Verdadeiro se conseguiu deletar os dados da SCR.
@history 02/06/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    Method DeletaSCR(xFil,xNum) Class APIExeJS
//====================================================================================================

    Local oDelet    := Nil 
    Local cCodDel   := "004"
    Local lRet      := .T.
    Local lDelSCR   := SuperGetMV("AP_DELSCR",.F.,.T.)

    If  lDelSCR 
        oDelet := APIExQry():New()
        oDelet:SetFormula(cCodDel)
        oDelet:AddFilter("TAB1", RetSqlName("SCR"))
        oDelet:AddFilter("FILTRO", "CR_FILIAL = '"+xFil+"' AND CR_NUM = '"+xNum+"' AND CR_TIPO = 'PC'")

        If .not. oDelet:ExecTCSQL()
            APIUtil():ConsoleLog("APIExeJS|DeletaSCR","Falha ao Executar o DELETE na tabela SCR Doc: "+xNum+".",3)
            lRet := .F.
        EndIf
        FWFreeObj(oDelet)
    Else 
        // Colocar aqui a Regra se verifica a tabela SCR antes de deletar os registros.
    EndIf 
Return lRet 

/*/{Protheus.doc} UneArrays
Metodo responsavel por unir 2 arrays na forma de cabeçalho e item.
@type Method 
@author Ricardo Tavares Ferreira
@since 11/04/2021
@version 12.1.27
@return array, Retorna o array tratado e unido.
@history 11/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    Method GetRegSC7(cNum,cItem,cOper) Class APIExeJS
//====================================================================================================

    Local oQuery    := Nil
    Local lExiste   := .T.
    Local aRet      := {}

    oQuery := APIExQry():New(.F.)
    oQuery:SetFormula("SC7")
    oQuery:SetHasHead(.F.)
    oQuery:AddFilter("TAB1",RetSqlName("SC7"))
    oQuery:AddFilter("CFILTRO","C7_NUM = '"+Alltrim(cNum)+"' AND C7_ITEM = '"+Alltrim(cItem)+"'")

    aRet := oQuery:Execute()
    If Len(aRet) > 0
        APIUtil():ConsoleLog("APIExeJS|GetRegSC7","O Item "+cItem+" existe no pedido de compra "+cNum+", sera executada a operação "+cOper+" com o LINPOS do execauto MATA120.",1)
    Else 
        APIUtil():ConsoleLog("APIExeJS|GetRegSC7","O Item "+cItem+" não existe no pedido de compra "+cNum+", sera executada a operação "+cOper+" sem o LINPOS do execauto MATA120.",1)
        lExiste := .F.
    EndIf
    FWFreeObj(oQuery)
Return lExiste    

/*/{Protheus.doc} UneArrays
Metodo responsavel por unir 2 arrays na forma de cabeçalho e item.
@type Method 
@author Ricardo Tavares Ferreira
@since 11/04/2021
@version 12.1.27
@return array, Retorna o array tratado e unido.
@history 11/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    Method UneArrays(aDadosCab,aDadosIte) Class APIExeJS
//====================================================================================================

    Local aDadosFim := {}
    Local nX        := 0
    Local nY        := 0
    Local nZ        := 0
    Local cIndexC    := ""
    Local cIndexI   := ""
    Local aDadAux   := {}
    Local cContIt   := ""
    Local cContAux  := ""
    Local aIteAux   := {}
    Local cValUni   := ""

    If ::aTab[1] == "SC5" .and. ::aTab[2] == "SC6"
        cIndexC := "C5_FILIAL/C5_NUM" // TODO - Depois pensar numa forma melhor de deixar isso dinamico.
        cIndexI := "C6_FILIAL/C6_NUM" // TODO - Depois pensar numa forma melhor de deixar isso dinamico.

        For nX := 1 To Len(aDadosCab)
            For nY := 1 To Len(aDadosCab[nX])
                If Alltrim(aDadosCab[nX][nY][1]) $ cIndexC
                    cValUni += Alltrim(aDadosCab[nX][nY][2])+"/"
                EndIf
            Next nY
            cValUni := SubStr(cValUni,1,Len(cValUni)-1)
            aadd(aDadAux,{aDadosCab[nX],cValUni})
            cValUni := ""
        Next nX 

        For nX := 1 To Len(aDadAux)
            For nY := 1 To Len(aDadosIte)
                For nZ := 1 To Len(aDadosIte[nY])
                    If Alltrim(aDadosIte[nY][nZ][1]) $ cIndexI
                        cContIt += Alltrim(aDadosIte[nY][nZ][2])+"/"
                    EndIf
                    cContAux := SubStr(cContIt,1,Len(cContIt)-1)
                    If cContAux == Alltrim(aDadAux[nX][2])
                        aadd(aIteAux,aDadosIte[nY])
                        Loop
                    EndIf
                Next nZ 
                cContIt := ""
            Next nY 
            aadd(aDadosFim,{aDadAux[nX][1],aIteAux})
            aIteAux := {}
        Next nX 
    Else 
        // Tratar na Sequencia as Demais tabelas
    EndIf 
Return aDadosFim    

/*/{Protheus.doc} RemoveDuplArray
Metodo responsavel por remover linhas duplicadas de um array multidimensional.
@type Method 
@author Ricardo Tavares Ferreira
@since 11/04/2021
@version 12.1.27
@return array, Retorna o array tratado eliminando os dados duplicados.
@history 11/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    Method RemoveDuplArray(aDados) Class APIExeJS
//====================================================================================================

    Local nX        := 0
    Local nY        := 0
    Local aRegAux   := {}
    Local cConteudo := ""
    Local aDadosFim := {}

    Default aDados  := {}

    If Len(aDados) > 0
        For nX := 1 To Len(aDados)
            For nY := 1 To Len(aDados[nX])
                If ValType(aDados[nX][nY][2]) == "N"
                    cConteudo += cValToChar(aDados[nX][nY][2])
                ElseIf ValType(aDados[nX][nY][2]) == "D"
                    cConteudo += Dtoc(aDados[nX][nY][2])
                Else 
                    cConteudo += aDados[nX][nY][2]
                EndIf
            Next nY 
            aadd(aRegAux,{aDados[nX],cConteudo})
            cConteudo := ""
        Next nX 

        For nX := 1 To Len(aRegAux)
            For nY := 1 To Len(aRegAux[nX][1])
                If ValType(aRegAux[nX][1][nY][2]) == "N"
                    cConteudo += cValToChar(aRegAux[nX][1][nY][2])
                ElseIf ValType(aRegAux[nX][1][nY][2]) == "D"
                    cConteudo += Dtoc(aRegAux[nX][1][nY][2])
                Else 
                    cConteudo += aRegAux[nX][1][nY][2]
                EndIf
            Next nY 
            If AScan(aDadosFim, {|x| x[2] == cConteudo}) == 0
                aadd(aDadosFim,{aRegAux[nX][1],cConteudo})
            EndIf
            cConteudo := ""
        Next nX 

        aRegAux := {}
        For nX := 1 To Len(aDadosFim)
            aadd(aRegAux,aDadosFim[nX][1])
        Next nX 
    EndIf
Return aRegAux 

/*/{Protheus.doc} ValidaFiltro
Valida o filtro enviado como parametro na requisição.
@type Method 
@author Ricardo Tavares Ferreira
@since 09/04/2021
@version 12.1.27
@return array, Retorna um array com a mensagem e o ok da validação.
@history 09/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    Method ValidaFiltro(cFiltro) Class APIExeJS
//====================================================================================================

    Local cMsgVal   := ""
    Local aCampos   := {}
    Local cTab      := ::aTab[1]
    Local nX        := 0
    Local nPos      := 0

    If Upper(cFiltro) $ "SELECT"
        cMsgVal := "Filtro Invalido. Não é possivel passar a palavra reservada SELECT no filtro. Utilize somente comandos de filtros SQL. Filtro informado ...: "
        Return {.F.,cMsgVal}
    ElseIf Upper(cFiltro) $ "INSERT"
        cMsgVal := "Filtro Invalido. Não é possivel passar a palavra reservada INSERT no filtro. Utilize somente comandos de filtros SQL. Filtro informado ...: "
        Return {.F.,cMsgVal}
    ElseIf Upper(cFiltro) $ "UPDATE"
        cMsgVal := "Filtro Invalido. Não é possivel passar a palavra reservada UPDATE no filtro. Utilize somente comandos de filtros SQL. Filtro informado ...: "
        Return {.F.,cMsgVal}
    ElseIf Upper(cFiltro) $ "DELETE"
        cMsgVal := "Filtro Invalido. Não é possivel passar a palavra reservada DELETE no filtro. Utilize somente comandos de filtros SQL. Filtro informado ...: "
        Return {.F.,cMsgVal}
    ElseIf Upper(cFiltro) $ "EXISTS"
        cMsgVal := "Filtro Invalido. Não é possivel passar a palavra reservada EXISTS no filtro. Utilize somente comandos de filtros SQL. Filtro informado ...: "
        Return {.F.,cMsgVal}
    ElseIf Upper(cFiltro) $ "GROUP"
        cMsgVal := "Filtro Invalido. Não é possivel passar a palavra reservada GROUP no filtro. Utilize somente comandos de filtros SQL. Filtro informado ...: "
        Return {.F.,cMsgVal}
    ElseIf Upper(cFiltro) $ "ORDER"
        cMsgVal := "Filtro Invalido. Não é possivel passar a palavra reservada ORDER no filtro. Utilize somente comandos de filtros SQL. Filtro informado ...: "
        Return {.F.,cMsgVal}
    ElseIf Upper(cFiltro) $ "INNER"
        cMsgVal := "Filtro Invalido. Não é possivel passar a palavra reservada INNER no filtro. Utilize somente comandos de filtros SQL. Filtro informado ...: "
        Return {.F.,cMsgVal}
    ElseIf Upper(cFiltro) $ "JOIN"
        cMsgVal := "Filtro Invalido. Não é possivel passar a palavra reservada JOIN no filtro. Utilize somente comandos de filtros SQL. Filtro informado ...: "
        Return {.F.,cMsgVal}
    ElseIf Upper(cFiltro) $ "WHERE"
        cMsgVal := "Filtro Invalido. Não é possivel passar a palavra reservada WHERE no filtro. Utilize somente comandos de filtros SQL. Filtro informado ...: "
        Return {.F.,cMsgVal}
    ElseIf Upper(cFiltro) $ "WITH"
        cMsgVal := "Filtro Invalido. Não é possivel passar a palavra reservada WITH no filtro. Utilize somente comandos de filtros SQL. Filtro informado ...: "
        Return {.F.,cMsgVal}
    ElseIf Upper(cFiltro) $ "FROM"
        cMsgVal := "Filtro Invalido. Não é possivel passar a palavra reservada FROM no filtro. Utilize somente comandos de filtros SQL. Filtro informado ...: "
        Return {.F.,cMsgVal}
    ElseIf Upper(cFiltro) $ "PIVOT"
        cMsgVal := "Filtro Invalido. Não é possivel passar a palavra reservada PIVOT no filtro. Utilize somente comandos de filtros SQL. Filtro informado ...: "
        Return {.F.,cMsgVal}
    ElseIf Upper(cFiltro) $ "UNPIVOT"
        cMsgVal := "Filtro Invalido. Não é possivel passar a palavra reservada UNPIVOT no filtro. Utilize somente comandos de filtros SQL. Filtro informado ...: "
        Return {.F.,cMsgVal}
    Endif

    DbSelectArea(cTab)
    aCampos := &(cTab)->(DbStruct())
	
	For nX := 1 To Len(aCampos)
		nPos := AT(Alltrim(aCampos[nX][1]),Upper(cFiltro),1)
        If nPos > 0
            cFiltro := StrTran(Upper(cFiltro),Alltrim(aCampos[nX][1]),"")
        EndIf
	Next

    nPos := 0
	nPos := AT("_",Upper(cFiltro),1)
    If nPos > 0
        cMsgVal := "O(s) campo(s) informado(s) no filtro não faz parte da estrutura de campos da tabela "+cTab+", utilize um campo da tabela para filtar a informação que deseja ou utilize outra forma de filtro. Filtro informado ...: "
    EndIf

    If .not. Empty(cMsgVal)
        Return {.F.,cMsgVal}
    EndIf

Return {.T.,cMsgVal}

/*/{Protheus.doc} GetFiltroPK
Busca o registro no banco de Dados Pela PK passada na API de Integração.
@type Method 
@author Ricardo Tavares Ferreira
@since 08/04/2021
@version 12.1.27
@return character, Filtro a ser adicionado pela consulta.
@history 08/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    Method GetFiltroPK() Class APIExeJS
//====================================================================================================

    Local cChave    := Decode64(::cPK)
    Local cTab      := ::aTab[1]
    Local cFiltroPK := ""

    DbSelectArea(cTab)
    &(cTab)->(DbSetOrder(1))

    If &(cTab)->(DbSeek(cChave))
        cFiltroPK := cTab+".R_E_C_N_O_ = "+cValToChar(&(cTab)->(Recno()))
    Else 
        APIUtil():ConsoleLog("APIExeJS|GetFiltroPK","Falha ao pocisionar no Registro com a PK: "+::cPK+" . Não será possivel retornar a informação solicitada.",4)
    EndIf
Return cFiltroPK

/*/{Protheus.doc} GetJsonResult
Metodo responsavel retornar o Json que será apresentado.
@type Method 
@author Ricardo Tavares Ferreira
@since 04/04/2021
@version 12.1.27
@return object, Objeto do Modelo de Dados.
@param lGrid, logical, Valida se esta processando um array do tipo Cabeçalho+Grid.
@param cInnerJoin, character, Amarração de duas tabelas ou mais quando for Cabeçalho+Grid. 
@param cFiltroRet, character, Filtro de Retorno.
@history 04/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    Method GetJsonResult(lGrid,cInnerJoin,cFiltroRet) Class APIExeJS
//====================================================================================================

    Local nCount        := 10
    Local StartIndex    := 1
    Local cNameJs       := "resources"
    Local cJsRet        := ""

    cJsRet := ::GetJsonQuery(nCount,StartIndex,cNameJs,cFiltroRet,lGrid,cInnerJoin)

    If Empty(cJsRet)
        APIUtil():ConsoleLog("APIExeJS|GetJsonResult","Falha na busca do Json de Retorno apos o processamento dos Dados.",4)
    EndIf
Return cJsRet 

/*/{Protheus.doc} GetModelSC7
Metodo responsavel por criar o modelo de Cadastro de Pedido de Compras.
@type Method 
@author Ricardo Tavares Ferreira
@since 04/04/2021
@version 12.1.27
@return object, Objeto do Modelo de Dados.
@history 04/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    Method GetModelSC7() Class APIExeJS
//====================================================================================================

    Local oModel    	:= Nil
    Local oStrSC7     	:= Nil
    Local aCampos   	:= {}
    Local cFieldSC7  	:= ""
    Local nX        	:= 0

    DbSelectArea("SC7")

    aCampos := SC7->(DbStruct())
	
	For nX := 1 To Len(aCampos)
		cFieldSC7 += aCampos[nX][1]
		cFieldSC7 += Iif((nX) < Len(aCampos),"|","")
	Next

    // Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("SC7MJS",/*{|| PreValida(oModel)}*/,/*{|oModel| PosValida(oModel)}*/,/*{|oModel|,fCommit(oModel)}*/,/*{|oModel|,fCancel(oModel)}*/) // Cria o objeto do Modelo de Dados

    // Cria o Objeto da Estrutura dos Campos da tabela
	oStrSC7 := FWFormStruct(1,"SC7",{|cCampo| ( Alltrim(cCampo) $ cFieldSC7 )})

    // Adiciona ao modelo um componente de formulario
	oModel:AddFields("M_SC7",/*cOwner*/,oStrSC7) 

    // Seta a chave primaria que sera utilizada na gravacao dos dados na tabela 
	oModel:SetPrimaryKey({"C7_NUM","C7_ITEM","C7_SEQUEN"})
Return oModel


/*/{Protheus.doc} MontaArrayExecAutoSC7
Metodo responsavel por montar o Array de Cabeçalho e Item para o ExecAuto.
@type Method 
@author Ricardo Tavares Ferreira
@since 03/04/2021
@version 12.1.27
@param cBody, character, Json recebido via requisição.
@return array, Array contendo os arrays de Cabeçalho e item.
@history 03/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
@history 07/04/2021, Ricardo Tavares Ferreira, Tratamento da mensagem de Retorno sendo ela o Json Completo ou uma mensagem comum.
/*/
//=============================================================================================================================
    Method MontaArrayExecAutoSC7(cBody) Class APIExeJS
//=============================================================================================================================

    Local aCabec        := {}
    Local aItens        := {}
    Local aDel          := {}
    Local nX            := 0
    Local nY            := 0
    Local aPedidos      := {}
    Local aDadosRet     := {}
    Local aLinha        := {}
    Local cItem         := ""
    Local xValor        := Nil
    Local oObj          := Nil
    Local cMsg          := ""
    Local cFilDel       := ""
    Local cNumDel       := ""
    Local cItemDel      := ""
    Local cSeqDel       := ""
    Local cFiltro       := ""
    Local cFilRet       := ""
    Local cNumRet       := ""
    Local cItemRet      := ""
    Local lRotNumPC     := .not. Empty(SuperGetMV("AP_ROTNPC",.F.,""))
    Local cFontNumPC    := ""
    Local lRotAprov     := .not. Empty(SuperGetMV("AP_ROTAPR",.F.,""))
    Local cRotAprov     := ""
    Local aRet          := {}
    Local cTabAtu       := ""
    Local cNumPC        := ""
    Local lIncPedSApv   := SuperGetMV("AP_PCSAPV",.F.,.F.)

    Public __aExcSet__  := {}
    Public __aExcFil__  := {}
    Public __cCodCC__   := ""
    Public __cCodIt__   := ""
    Public __cCodCl__   := ""

    If lRotNumPC
        cFontNumPC := Alltrim(SuperGetMV("AP_ROTNPC",.F.,""))
    EndIf 

    If lRotAprov
        cRotAprov := Alltrim(SuperGetMV("AP_ROTAPR",.F.,""))
    EndIf

    If .not. Empty(cBody)
        If FWJsonDeserialize(cBody,@oObj)
            For nX := 1 To Len(oObj)
                aDadosRet := ClassDataArr(oObj[nX])
                aadd(aPedidos,aDadosRet)
                aDadosRet := {}
            Next nX

            For nX := 1 To Len(aPedidos)
                For nY := 1 To Len(aPedidos[nX])
                    If Alltrim(aPedidos[nX][nY][1]) == "C7_FILIAL"
                        cFilDel := Alltrim(aPedidos[nX][nY][2])
                        cFilRet := Alltrim(aPedidos[nX][nY][2])
                    EndIf
                    If Alltrim(aPedidos[nX][nY][1]) == "C7_NUM"
                        cNumDel := Alltrim(aPedidos[nX][nY][2])
                        cNumRet := Alltrim(aPedidos[nX][nY][2])
                    EndIf
                    If Alltrim(aPedidos[nX][nY][1]) == "C7_ITEM"
                        cItemDel := Alltrim(aPedidos[nX][nY][2])
                        cItemRet += Alltrim(aPedidos[nX][nY][2])+"/"
                    EndIf
                    If Alltrim(aPedidos[nX][nY][1]) == "C7_SEQUEN"
                        cSeqDel := Alltrim(aPedidos[nX][nY][2])
                    EndIf
                    If Alltrim(aPedidos[nX][nY][1]) == "C7_CC"
                        __cCodCC__ := Alltrim(aPedidos[nX][nY][2])
                    EndIf
                    If Alltrim(aPedidos[nX][nY][1]) == "C7_ITEMCTA"
                        __cCodIt__ := Alltrim(aPedidos[nX][nY][2])
                    EndIf
                    If Alltrim(aPedidos[nX][nY][1]) == "C7_CLVL"
                        __cCodCl__ := Alltrim(aPedidos[nX][nY][2])
                    EndIf
                Next nY 
                Aadd(aDel,{PadR(cFilDel,TamSx3("C7_FILIAL")[1]),PadR(cNumDel,TamSx3("C7_NUM")[1]),PadR(cItemDel,TamSx3("C7_ITEM")[1]),PadR(cSeqDel,TamSx3("C7_SEQUEN")[1])})
            Next nX 

            if self:cOper <> "DELETE"
                If .not. Empty(cRotAprov)
                    &(cRotAprov)
                EndIf
            EndIf

            For nX := 1 To Len(aPedidos)
                For nY := 1 To Len(aPedidos[nX])
                    If Upper(Alltrim(aPedidos[nX][nY][1])) <> "PK"
                        If Alltrim(aPedidos[nX][nY][1]) == "C7_ITEM"
                            cItem := Alltrim(aPedidos[nX][nY][2])
                        EndIf
                        If TamSx3(Alltrim(aPedidos[nX][nY][1]))[3] == "N"
                            xValor := aPedidos[nX][nY][2]
                        ElseIf TamSx3(Alltrim(aPedidos[nX][nY][1]))[3] == "D"
                            xValor := Stod(aPedidos[nX][nY][2])
                        Else 
                            xValor := Alltrim(aPedidos[nX][nY][2])
                        EndIf
                        If Alltrim(aPedidos[nX][nY][1]) $ "C7_FILIAL|C7_NUM|C7_EMISSAO|C7_FORNECE|C7_LOJA|C7_COND|C7_CONTATO|C7_FILENT"
                            If Alltrim(::cOper) == "POST"
                                If Alltrim(aPedidos[nX][nY][1]) <> "C7_NUM"
                                    If nX == 1 
                                        aadd(aCabec,{aPedidos[nX][nY][1],xValor,Nil})
                                    EndIf
                                Else 
                                    If lRotNumPC
                                        If nX == 1 
                                            If .not. Empty(cFontNumPC)
                                                xValor := &(cFontNumPC)
                                                cNumPC := xValor
                                                aadd(aCabec,{aPedidos[nX][nY][1],xValor,Nil})
                                            EndIf 
                                        EndIf
                                    Else 
                                        cNumPC := ""
                                    EndIf 
                                Endif
                            Else 
                                If nX == 1 
                                    If Alltrim(aPedidos[nX][nY][1]) == "C7_NUM"
                                        cNumPC := xValor
                                    EndIf 
                                    aadd(aCabec,{aPedidos[nX][nY][1],xValor,Nil})
                                EndIf
                            EndIf
                        Else 
                            If Alltrim(aPedidos[nX][nY][1]) == "C7_APROV"
                                If .not. Empty(__cGrupo__)
                                    xValor := __cGrupo__
                                    //__cGrupo__ := ""
                                Else 
                                    If .not. lIncPedSApv
                                        If Alltrim(::cOper) $ "POST/PUT"
                                            APIUtil():ConsoleLog("APIExeJS|MontaArrayExecAutoSC7","Não é possivel incluir/alterar um pedido de compra sem grupo de aprovação. Para que seja possivel incluir o pedido sem grupo, ative o parametro AP_PCSAPV colocando ele como verdadeiro.",4)
                                            cMsg := "Não é possivel incluir/alterar um pedido de compra sem grupo de aprovação. Para que seja possivel incluir o pedido sem grupo, ative o parametro AP_PCSAPV colocando ele como verdadeiro."
                                            ::SetRespError(500,cMsg)
                                            Return {{},{},{},"",cMsg}
                                        EndIf
                                    EndIf
                                EndIf
                            EndIf
                            aadd(aLinha,{aPedidos[nX][nY][1],xValor,Nil})
                        EndIf
                    EndIf
                Next nY

                aLinha := FWVetByDic(aLinha,"SC7")

                If Alltrim(::cOper) == "PUT"
                    If ::GetRegSC7(cNumRet,cItem,Alltrim(::cOper))
                        aAdd(aLinha,{"LINPOS","C7_ITEM" ,cItem})
                    EndIf
                    aAdd(aLinha,{"AUTDELETA","N" ,Nil})
                EndIf 

                aadd(aItens,aLinha)
                aLinha := {}
            Next nX

            aCabec := FWVetByDic(aCabec,"SC7")

            cTabAtu := ::aTab[1]
            aRet := APIUtil():GetCpoZR1(aPedidos,cTabAtu,cNumPC)

            __aExcSet__ := aRet[1]
            __aExcFil__ := aRet[2]

            If .not. Empty(cFilDel)
                cFiltro += "C7_FILIAL = '"+cFilDel+"' "
            EndIf

            If .not. Empty(cItemRet)
                If Right(cItemRet,1) == "/"
                    cItemRet := Substr(cItemRet,1,Len(cItemRet)-1)
                EndIf
                If .not. Empty(cFiltro)
                    cFiltro += "AND C7_ITEM IN "+FormatIn(cItemRet,'/')+" "
                Else 
                    cFiltro += "C7_ITEM IN "+FormatIn(cItemRet,'/')+" "
                EndIf
            EndIf
            If .not. Empty(cNumRet)
                If .not. Empty(cFiltro)
                    cFiltro += "AND C7_NUM = '"+cNumRet+"' "
                Else 
                    cFiltro += "C7_NUM = '"+cNumRet+"' "
                EndIf
            EndIf
        Else 
            APIUtil():ConsoleLog("APIExeJS|MontaArrayExecAutoSC7","Falha na conversão so cBody em objeto operação executada ("+Upper(::cOper)+").",4)
            cMsg := "Falha na conversão so cBody em objeto operação executada ("+Upper(::cOper)+")."
            ::SetRespError(500,cMsg)
            Return {aCabec,aItens,aDel,cFiltro,cMsg}
        EndIf
    Else 
        APIUtil():ConsoleLog("APIExeJS|MontaArrayExecAutoSC7","O Body enviado por requisição está vazio, não será possivel prosseguir com a operação "+Upper(::cOper)+".",4)
        cMsg := "O Body enviado por requisição está vazio, não será possivel prosseguir com a operação "+Upper(::cOper)+"."
        ::SetRespError(500,cMsg)
        Return {aCabec,aItens,aDel,cFiltro,cMsg}
    EndIf   
Return {aCabec,aItens,aDel,cFiltro,cMsg}

/*/{Protheus.doc} SetRespSuce
Metodo responsavel por setar o codigo e mensagem de erro.
@type Method 
@author Ricardo Tavares Ferreira
@since 03/04/2021
@version 12.1.27
@param nCod, numeric, Código do erro para ser retornado.
@param cMsg, character, Mensagem a ser retornada.
@history 03/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//=============================================================================================================================
    Method SetRespSuce(nCod,cMsg) Class APIExeJS
//=============================================================================================================================

    Local cJson      := ""
    Local oJsReponse := Nil

    oJsReponse := JsonObject():New()
    oJsReponse["Code"]     := nCod
    oJsReponse["Message"]  := cMsg

    cJson := EncodeUtf8(oJsReponse:ToJson())
    FWFreeObj(oJsReponse)
Return cJson

/*/{Protheus.doc} ProcessaOperacaoSC7
Metodo responsavel por pegar o Json retornado e salvar as informações no sistema.
@type Method 
@author Ricardo Tavares Ferreira
@since 03/04/2021
@version 12.1.27
@param cBody, character, Json enviado na requisição.
@return character, Retorna um json com a operação realizada pelo ExecAuto.
@history 03/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
@history 07/04/2021, Ricardo Tavares Ferreira, Tratamento da mensagem de Retorno sendo ela o Json Completo ou uma mensagem comum.
/*/
//=============================================================================================================================
    Method ProcessaOperacaoSC7(cBody) Class APIExeJS
//=============================================================================================================================

    Local cMsg      := ""
    Local nOper     := 0
    Local aCabec    := {}
    Local aItens    := {}
    Local aDados    := {}
    Local nX        := 0
    Local nZ        := 0
    Local aLogError := {}
    Local cError    := ""
    Local cJsRet    := ""
    Local nCod      := 0
    Local aDel      := {}
    Local oModel    := Nil
    Local aErroDel  := {}
    Local lRetJson  := SuperGetMV("AP_JSORMSG",.F.,.F.) 
    Local cFiltroRet:= ""

    Private lMsHelpAuto     := .T.
    Private lMsErroAuto     := .F. 
    Private lAutoErrNoFile  := .T.

    Default cBody := ""

    If Alltrim(::cOper) == "POST"
        nOper := 3
    ElseIf Alltrim(::cOper) == "PUT"
        nOper := 4
    ElseIf Alltrim(::cOper) == "DELETE"
        nOper := 5
    EndIf

    If .not. Empty(cBody)
        aDados      := ::MontaArrayExecAutoSC7(cBody)
        aCabec      := aDados[1]
        aItens      := aDados[2]
        aDel        := aDados[3]
        cFiltroRet  := aDados[4]

        If ::aTab[1] == "SC7"
            If Alltrim(::cOper) == "POST" .or. Alltrim(::cOper) == "PUT"
                If Len(aCabec) > 0 .and. Len(aItens) > 0
                    MSExecAuto({|a,b,c,d,e| MATA120(a,b,c,d,e)},1,aCabec,aItens,nOper,.F.) // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
                Else 
                    If Len(aCabec) <= 0
                        APIUtil():ConsoleLog("APIExeJS|ProcessaOperacaoSC7","O Array (aCabec), está vazio, não será possivel prosseguir com a operação "+Upper(::cOper)+".",4)
                        cMsg := "O Array (aCabec), está vazio, não será possivel prosseguir com a operação "+Upper(::cOper)+"."
                        ::SetRespError(500,aDados[5])
                        Return cJsRet
                    EndIf
                    If Len(aItens) <= 0
                        APIUtil():ConsoleLog("APIExeJS|ProcessaOperacaoSC7","O Array (aItens), está vazio, não será possivel prosseguir com a operação "+Upper(::cOper)+".",4)
                        cMsg := "O Array (aItens), está vazio, não será possivel prosseguir com a operação "+Upper(::cOper)+"."
                        ::SetRespError(500,aDados[5])
                        Return cJsRet
                    EndIf
                EndIf
            EndIf 
            If Alltrim(::cOper) == "DELETE"
                If Len(aDel) > 0
                    DbSelectArea("SC7")
                    SC7->(DbSetOrder(1))

                    For nX := 1 To Len(aDel)
                        If SC7->(DbSeek(aDel[nX][1]+aDel[nX][2]+aDel[nX][3]+aDel[nX][4]))
                            If SC7->C7_QTDACLA <= 0
                                If  ::DeletaSCR(Alltrim(SC7->C7_FILIAL),Alltrim(SC7->C7_NUM))
                                    oModel := ::GetModelSC7()   
                                    oModel:SetOperation(5)
                                    oModel:Activate()

                                    If oModel:VldData()
                                        oModel:CommitData()
                                        If lRetJson
                                            cJsRet := ::GetJsonResult(.F.,"",cFiltroRet)
                                            nCod := 203
                                            cMsg := "Pedido excluido com sucesso."
                                        Else
                                            nCod := 203
                                            cMsg := "Pedido excluido com sucesso."
                                            cJsRet := ::SetRespSuce(nCod,cMsg)
                                        EndIf
                                        APIUtil():ConsoleLog("APIExeJS|ProcessaOperacaoSC7",cValToChar(nCod)+" - "+cMsg+". "+aDel[nX][2]+"|"+aDel[nX][3],1)
                                        oModel:DeActivate()
                                    Else 
                                        aErroDel := oModel:GetErrorMessage()
                                        For nZ := 1 To Len(aErroDel)
                                            If .not. Empty(aErroDel[nZ])
                                                cError += aErroDel[nZ] +chr(13)+chr(10)
                                            EndIf
                                        Next nZ
                                        APIUtil():ConsoleLog("APIExeJS|ProcessaOperacaoSC7","Erro: 500 - "+cError,4)
                                        cMsg := cError
                                        ::SetRespError(500,cMsg)
                                        oModel:DeActivate()
                                        Return cJsRet
                                    EndIf
                                Else 
                                    APIUtil():ConsoleLog("APIExeJS|ProcessaOperacaoSC7","Falha ao deletar os dados da tabela SCR Documento NUM: "+Alltrim(SC7->C7_NUM),4)
                                    cMsg := "Falha ao deletar os dados da tabela SCR Documento NUM: "+Alltrim(SC7->C7_NUM)
                                    ::SetRespError(500,cMsg)
                                     oModel:DeActivate()
                                    Return cJsRet
                                EndIf
                            Else 
                                APIUtil():ConsoleLog("APIExeJS|ProcessaOperacaoSC7","O pedido "+Alltrim(SC7->C7_NUM)+"/"+Alltrim(SC7->C7_ITEM)+", não pode ser excluido pois ja existe Pré-nota ou documento de entrada gerado.",4)
                                cMsg := "O pedido "+Alltrim(SC7->C7_NUM)+"/"+Alltrim(SC7->C7_ITEM)+", não pode ser excluido pois ja existe Pré-nota ou documento de entrada gerado."
                                ::SetRespError(500,cMsg)
                                Return cJsRet
                            EndIf
                        Else 
                            APIUtil():ConsoleLog("APIExeJS|ProcessaOperacaoSC7","Falha ao posicionar no registro do Pedido de Compras para a Deleção.",4)
                            cMsg := "Falha ao posicionar no registro do Pedido de Compras para a Deleção."
                            ::SetRespError(500,cMsg)
                            Return cJsRet
                        EndIf
                    Next nX
                Else 
                    APIUtil():ConsoleLog("APIExeJS|ProcessaOperacaoSC7","O Array (aDel), está vazio, não será possivel prosseguir com a operação "+Upper(::cOper)+".",4)
                    cMsg := "O Array (aDel), está vazio, não será possivel prosseguir com a operação "+Upper(::cOper)+"."
                    ::SetRespError(500,cMsg)
                    Return cJsRet
                EndIf
            EndIf
        Else 
            APIUtil():ConsoleLog("APIExeJS|ProcessaOperacaoSC7","O Metódo "+Upper(::cOper)+" para o serviço "+Alltrim(::cIdServ)+"/"+Alltrim(::cItemServ)+" não tem esta funcionalidade implementada no momento. Procure o setor de T.I para verificar a possibilidade de implementação/liberação desta operação.",4)
            cMsg := "O Metódo "+Upper(::cOper)+" para o serviço "+Alltrim(::cIdServ)+"/"+Alltrim(::cItemServ)+" não tem esta funcionalidade implementada no momento. Procure o setor de T.I. para verificar a possibilidade de implementação/liberação desta operação."
            ::SetRespError(500,cMsg)
            Return cJsRet
        EndIf
        If Alltrim(::cOper) == "POST" .or. Alltrim(::cOper) == "PUT"
            If lMsErroAuto
                aLogError := GetAutoGRLog()
                For nX := 1 To Len(aLogError)
                    cError += aLogError[nX] +chr(13)+chr(10)
                Next

                APIUtil():ConsoleLog("APIExeJS|ProcessaOperacaoSC7","Erro: 500 - "+cError,4)
                cMsg := cError
                ::SetRespError(500,cMsg)
                Return cJsRet
            Else
                If Alltrim(::cOper) == "POST"
                    If .not. Empty(cFiltroRet)
                        cFiltroRet := cFiltroRet +"AND C7_NUM = '"+Alltrim(SC7->C7_NUM)+"'"
                    Else 
                        cFiltroRet := cFiltroRet +"C7_NUM = '"+Alltrim(SC7->C7_NUM)+"'"
                    EndIf
                Endif
                If lRetJson
                    cJsRet := ::GetJsonResult(.F.,"",cFiltroRet)
                    If nOper == 3
                        nCod := 201
                        cMsg := "Pedido criado com sucesso."
                    ElseIf nOper == 4
                        nCod := 202
                        cMsg := "Pedido alterado com sucesso."
                    ElseIf nOper == 5
                        nCod := 203
                        cMsg := "Pedido excluido com sucesso."
                    EndIf
                Else
                    If nOper == 3
                        nCod := 201
                        cMsg := "Pedido criado com sucesso."
                    ElseIf nOper == 4
                        nCod := 202
                        cMsg := "Pedido alterado com sucesso."
                    ElseIf nOper == 5
                        nCod := 203
                        cMsg := "Pedido excluido com sucesso."
                    EndIf
                    cJsRet := ::SetRespSuce(nCod,cMsg)
                EndIf
            Endif 
            APIUtil():ConsoleLog("APIExeJS|ProcessaOperacaoSC7",cValToChar(nCod)+" - "+cMsg+".",1)
        EndIf 
    Else 
        APIUtil():ConsoleLog("APIExeJS|ProcessaOperacaoSC7","O Body Enviado está vazio, por este motivo não será possivel gravar as informações.",4)
        cMsg := "O Body Enviado está vazio, por este motivo não será possivel gravar as informações. Codigo do serviço "+Alltrim(::cIdServ)+"/"+Alltrim(::cItemServ)+"."
        ::SetRespError(500,cMsg)
        Return cJsRet
    EndIf
Return cJsRet 

/*/{Protheus.doc} ValidaOperacao
Metodo responsavel por validar se o usuario tem acesso para executar o metodo selecionado.
@type Method 
@author Ricardo Tavares Ferreira
@since 03/04/2021
@version 12.1.27
@return logical, Retorna verdadeiro se validou o usuario.
@history 03/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
@history 12/04/2021, Ricardo Tavares Ferreira, Tratamento no retorno da tabela conforme a empresa posicionada.
/*/
//=============================================================================================================================
    Method ValidaOperacao() Class APIExeJS
//=============================================================================================================================

    Local oQuery    := Nil
    Local cCodQry 	:= "ZR0"
    Local aRet      := {}
    Local cMsg      := ""
    Local cFiltroOp := ""

    If Upper(::cOper) == "GET"
        cFiltroOp := " AND ZR0_GET = 'T'"
    ElseIf Upper(::cOper) == "POST"
        cFiltroOp := " AND ZR0_POST = 'T'"
    ElseIf Upper(::cOper) == "PUT"
        cFiltroOp := " AND ZR0_PUT = 'T'"
    ElseIf Upper(::cOper) == "DELETE"
        cFiltroOp := " AND ZR0_DELETE = 'T'"
    EndIf

    oQuery := APIExQry():New(.F.)
    oQuery:SetFormula(cCodQry)
    oQuery:SetHasHead(.F.)
    oQuery:AddFilter("TAB1", RetSqlName("ZR0"))
    oQuery:AddFilter("CFILTRO" , "ZR0_USER = '"+::cIdUser+"' AND ZR0_SERV = '"+Alltrim(::cIdServ)+"' AND ZR0_ITEM = '"+Alltrim(::cItemServ)+"' "+cFiltroOp+"")

    aRet := oQuery:Execute()
    If Len(aRet) > 0
        APIUtil():ConsoleLog("APIExeJS|ValidaOperacao","Operação "+Upper(::cOper)+" validada para o usuário "+Alltrim(::cIdUser)+" no serviço "+Alltrim(::cIdServ)+".",1)
    Else 
        APIUtil():ConsoleLog("APIExeJS|ValidaOperacao","O usuário "+Alltrim(::cIdUser)+" não tem permissão para utilizar o metódo "+Upper(::cOper)+" para o serviço "+Alltrim(::cIdServ)+".",4)
        cMsg := "O usuário "+Alltrim(::cIdUser)+" não tem permissão para utilizar o metódo "+Upper(::cOper)+" para o serviço "+Alltrim(::cIdServ)+"."
        ::SetRespError(500,cMsg)
        Return .F.
    EndIf
    FWFreeObj(oQuery)
Return .T. 

/*/{Protheus.doc} TransformArraytoJson
Metodo responsavel por retornar os campos para a criação do select.
@type Method 
@author Ricardo Tavares Ferreira
@since 02/04/2021
@version 12.1.27
@param aDados, array, Array contendo os dados para a montagem do Json de Retorno.
@param cNomeJs, character, Nome do nó que será utilizado na montagem do Json por padrao será "resources".
@param nCount, numeric, Quantidade de registros que serão retornados.
@param StartIndex, numeric, paginação do Json.
@param lGrid, logical, Define se irá montar um Json com cabeçalho e grid.
@param cCamposCab, character, Campos retornados do cadastro de campos da API - Cabeçalho.
@param cCamposGrid, character, Campos retornados do cadastro de campos da API - Grid.
@return character, Json que será utilizado na apresentação dos dados.
@history 02/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
@history 10/04/2021, Ricardo Tavares Ferreira, Tratamento para APIs que tem cabeçalho e Grid.
/*/
//=============================================================================================================================
    Method TransformArraytoJson(aDados,cNameJs,nCount,StartIndex,lGrid,cCamposCab,cCamposGrid) Class APIExeJS
//=============================================================================================================================

    Local oJsonRes  := Nil
    Local oJsResult := JsonObject():New()
    Local aJsonReg  := {}
    Local nQtdRegs  := 0
    Local nLimite   := 0
    Local nReg      := 0
    Local cJsRet    := ""
    Local nX        := 0
    Local nY        := 0
    Local nZ        := 0
    Local cChaveUn  := ""
    Local cIndex    := ""
    Local cIndexIt  := ""
    Local cNameItJs := "itens"
    Local cTabC     := ""
    Local cTabI     := ""
    Local aDadosCab := {}
    Local aDadosIte := {}
    Local aCabAux   := {}
    Local aIteAux   := {}
    Local aDadosFim := {}
    Local aJsItem   := {}
    Local aJsCab    := {}
    Local nPos      := 0

    Default nCount      := 10
    Default StartIndex  := 1
    Default cNameJs     := "resources"

    If StartIndex < 1
        StartIndex := 1
    EndIf

    If .not. lGrid
        cTabC := ::aTab[1]

        DbSelectArea(cTabC)
        cIndex := &(cTabC)->(IndexKey(1))
        nQtdRegs := Len(aDados)

        If (StartIndex+nCount) > nQtdRegs
            nLimite := nQtdRegs
        Else
            nLimite := StartIndex+nCount-1
        EndIf

        oJsResult["total"]       := nQtdRegs
        oJsResult["count"]       := nCount
        oJsResult["startindex"]  := StartIndex

        For nReg := StartIndex to nLimite
            oJsonRes  := JsonObject():new()
            For nX := 1 To Len(aDados[nReg])
                oJsonRes[aDados[nReg][nX][1]] := Iif(ValType(aDados[nReg][nX][2]) == "C",Alltrim(APIUtil():PolyString(aDados[nReg][nX][2],.F.,"C")),aDados[nReg][nX][2])
                If Alltrim(aDados[nReg][nX][1]) $ cIndex
                    cChaveUn += aDados[nReg][nX][2]
                EndIf
            Next nX
            oJsonRes["pk"] := Encode64(cChaveUn)
            Aadd(aJsonReg,oJsonRes)
            oJsonRes := Nil
            cChaveUn := ""
        Next nReg
        oJsResult[cNameJs] := aJsonReg
    Else 
        cTabC := ::aTab[1]
        cTabI := ::aTab[2]

        DbSelectArea(cTabC)
        cIndex := &(cTabC)->(IndexKey(1))

        DbSelectArea(cTabI)
        cIndexIt := &(cTabI)->(IndexKey(1))

        For nX := 1 To Len(aDados)
            For nY := 1 To Len(aDados[nX])
                If Alltrim(aDados[nX][nY][1]) $ cCamposCab
                    Aadd(aCabAux,{aDados[nX][nY][1],aDados[nX][nY][2]})
                EndIf
                If Alltrim(aDados[nX][nY][1]) $ cCamposGrid
                    Aadd(aIteAux,{aDados[nX][nY][1],aDados[nX][nY][2]})
                EndIf
            Next nY
            aCabAux := FWVetByDic(aCabAux,cTabC)
            aIteAux := FWVetByDic(aIteAux,cTabI)
            Aadd(aDadosCab,aCabAux)
            Aadd(aDadosIte,aIteAux)
            aCabAux := {}
            aIteAux := {}
        Next nX 

        aDadosCab := ::RemoveDuplArray(aDadosCab)
        aDadosIte := ::RemoveDuplArray(aDadosIte)

        aDadosFim := ::UneArrays(aDadosCab,aDadosIte)
        nQtdRegs  := Len(aDadosFim)

        If (StartIndex+nCount) > nQtdRegs
            nLimite := nQtdRegs
        Else
            nLimite := StartIndex+nCount-1
        EndIf

        oJsResult["total"]       := nQtdRegs
        oJsResult["count"]       := nCount
        oJsResult["startindex"]  := StartIndex

        For nReg := StartIndex to nLimite  
            aadd(aJsCab,JsonObject():new())
            nPos := Len(aJsCab)        
            For nX := 1 To Len(aDadosFim[nReg])
                For nY := 1 To Len(aDadosFim[nReg][nX])
                    If nX == 1
                        aJsCab[nPos][aDadosFim[nReg][nX][nY][1]] := Iif(ValType(aDadosFim[nReg][nX][nY][2]) == "C",Alltrim(APIUtil():PolyString(aDadosFim[nReg][nX][nY][2],.F.,"C")),aDadosFim[nReg][nX][nY][2])
                        If Alltrim(aDadosFim[nReg][nX][nY][1]) $ cIndex
                            cChaveUn += aDadosFim[nReg][nX][nY][2]
                        EndIf
                    Else 
                        aadd(aJsItem,JsonObject():new())
                        nPosIt := Len(aJsItem)
                        For nZ := 1 To Len(aDadosFim[nReg][nX][nY])
                            aJsItem[nPosIt][aDadosFim[nReg][nX][nY][nZ][1]] := Iif(ValType(aDadosFim[nReg][nX][nY][nZ][2]) == "C",Alltrim(APIUtil():PolyString(aDadosFim[nReg][nX][nY][nZ][2],.F.,"C")),aDadosFim[nReg][nX][nY][nZ][2])
                        Next nZ
                    EndIf 
                Next nY   
            Next nX
            aJsCab[nPos]["pk"] := Encode64(cChaveUn)
            aJsCab[nPos][cNameItJs] := aJsItem
            aJsItem := {}
            cChaveUn := ""
        Next nReg
        oJsResult[cNameJs] := aJsCab
        aJsCab := {}
    EndIf
    cJsRet := EncodeUtf8(oJsResult:ToJson())
    oJsResult := Nil
Return cJsRet 

/*/{Protheus.doc} GetCamposServ
Metodo responsavel por retornar os campos para a criação do select.
@type Method 
@author Ricardo Tavares Ferreira
@since 02/04/2021
@version 12.1.27
@param cTab, character, Codigo da Tabela cadastrada na tabela ZR1.
@param cItem, character, Codigo do Item cadastrado na tabela ZR1.
@return array, Array contendo os campos de cabeçalho e item cadastrados na tabela ZR1.
@history 02/04/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Method GetCamposServ(cTab,cItem) Class APIExeJS
//=============================================================================================================================

    Local cCpoCab   := ""
    Local nX        := 0
    Local aCpoCab   := {}
    Local aCpoIte   := {}
    Local cCpoFCb   := ""
    Local cCpoFIt   := ""
    Local aCpoMemo  := {}
    Local cCpoRetC  := ""
    Local cCpoRetI  := ""

    DbSelectArea("ZR1")
    ZR1->(DbSetOrder(2))

    If ZR1->(DbSeek(FWXFilial("ZR1")+cTab+cItem))
        cCpoCab := ZR1->ZR1_CAMPOS
        cCpoIte := ZR1->ZR1_CPOITE
        aCpoCab := Strtokarr(cCpoCab,"|")
        aCpoIte := Strtokarr(cCpoIte,"|")

        For nX := 1 To Len(aCpoCab)
            If Alltrim(Posicione("SX3",2,aCpoCab[nX],"X3_CONTEXT")) == "V"
                APIUtil():ConsoleLog("APIExeJS|GetCamposServ","O campo "+Alltrim(aCpoCab[nX])+" é Virtual, por este motivo nao será possivel retornar as informações deste campo, pois a mesma nao é salva no banco de dados.",1)
            Else
                If FWSX3Util():GetFieldType(aCpoCab[nX]) == "M"
                    aadd(aCpoMemo,Alltrim(aCpoCab[nX]))
                    cCpoRetC += Iif(nX >= Len(aCpoCab),Alltrim(aCpoCab[nX]),Alltrim(aCpoCab[nX])+",")
                Else 
                    cCpoFCb  += Iif(nX >= Len(aCpoCab),Alltrim(aCpoCab[nX]),Alltrim(aCpoCab[nX])+",")
                    cCpoRetC += Iif(nX >= Len(aCpoCab),Alltrim(aCpoCab[nX]),Alltrim(aCpoCab[nX])+",")
                EndIf
            EndIf
        Next nX

        For nX := 1 To Len(aCpoIte)
            If Alltrim(Posicione("SX3",2,aCpoIte[nX],"X3_CONTEXT")) == "V"
                APIUtil():ConsoleLog("APIExeJS|GetCamposServ","O campo "+Alltrim(aCpoIte[nX])+" é Virtual, por este motivo nao será possivel retornar as informações deste campo, pois a mesma nao é salva no banco de dados.",1)
            Else
                If FWSX3Util():GetFieldType(aCpoIte[nX]) == "M"
                    aadd(aCpoMemo,Alltrim(aCpoIte[nX]))
                    cCpoRetI += Iif(nX >= Len(aCpoIte),Alltrim(aCpoIte[nX]),Alltrim(aCpoIte[nX])+",")
                Else 
                    cCpoFIt  += Iif(nX >= Len(aCpoIte),Alltrim(aCpoIte[nX]),Alltrim(aCpoIte[nX])+",")
                    cCpoRetI += Iif(nX >= Len(aCpoIte),Alltrim(aCpoIte[nX]),Alltrim(aCpoIte[nX])+",")
                EndIf
            EndIf
        Next nX
    Else 
        APIUtil():ConsoleLog("APIExeJS|GetCamposServ","Falha ao posicionar na tabela ZR1 para a busca dos campos.",4)
    EndIf
Return {cCpoFCb,cCpoFIt,aCpoMemo,cCpoRetC,cCpoRetI}

/*/{Protheus.doc} GetJsonQuery
Metodo responsavel por setar o codigo e mensagem de erro.
@type Method 
@author Ricardo Tavares Ferreira
@since 02/04/2021
@version 12.1.27
@param nCount, numeric, Numero de registros que vao ser retornados.
@param StartIndex, numeric, Indice de inicio para busca das informações.
@param cNameJs, character, Nome do modulo do Json que será retornado, padrao será "resources".
@param cFiltro, character, Filtro passado como paramentro para a busca dos registros.
@param lGrid, logical, Definese o retorno será composto por cabeçalho e grid.
@param cInnerJoin, character, Inner join para quando a tabela possuir amarração entre outras tabelas.
@return character, Retorna o Json consultado.
@history 02/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
@history 07/04/2021, Ricardo Tavares Ferreira, Solução para retornar no arquivo e log o nome da tabela enviada pela requisição da API.
@history 07/04/2021, Ricardo Tavares Ferreira, Tratamento da mensagem de Retorno sendo ela o Json Completo ou uma mensagem comum.
@history 08/04/2021, Ricardo Tavares Ferreira, Tratamento no filtro pela PK do registro.
@history 09/04/2021, Ricardo Tavares Ferreira, Tratamento na Validação do Filtro passado no parametro da requisição.
@history 10/04/2021, Ricardo Tavares Ferreira, Tratamento para APIs que tem cabeçalho e Grid.
/*/
//=============================================================================================================================
    Method GetJsonQuery(nCount,StartIndex,cNameJs,cFiltro,lGrid,cInnerJoin) Class APIExeJS
//=============================================================================================================================
    
    Local cJsonRet   := ""
    Local cQuery     := ""
    Local oQuery     := Nil
    Local aCampos    := {}
    Local cMsg       := ""
    Local QbLinha	 := chr(13)+chr(10)
    Local aRet       := {}
    Local cCampoFil  := ""
    Local cJsEmpty   := '{"resources": [],"startindex": 1,"count": 0,"total": 0}'
    Local lFiltraFil := SuperGetMV("AP_FFILIAL",.F.,.T.)
    Local cFiltroPK  := ""
    Local aValFiltro := {}
    Local nX         := 0

    If .not. Empty(cFiltro)
        aValFiltro := ::ValidaFiltro(cFiltro)
        If .not. aValFiltro[1]
            APIUtil():ConsoleLog("APIExeJS|GetJsonQuery",aValFiltro[2] + Alltrim(cFiltro),4)
            cMsg := aValFiltro[2] + Alltrim(cFiltro)
            ::SetRespError(500,cMsg)
            Return cJsonRet
        EndIf
    EndIf 

    If .not. Empty(::cPK)
        cFiltroPK := ::GetFiltroPK(::cPK)
        If Empty(cFiltroPK)
            APIUtil():ConsoleLog("APIExeJS|GetJsonQuery","Consulta nao executada para a PK informada, envie uma PK valida ou utilize outro metódo de pesquisa. PK enviada..: "+Alltrim(::cPK),4)
            cMsg := "Consulta nao executada para a PK informada, envie uma PK valida ou utilize outro metódo de pesquisa. PK enviada..: "+Alltrim(::cPK)
            ::SetRespError(500,cMsg)
            Return cJsonRet
        EndIf
    EndIf

    cCampoFil := ::aTab[1]+"_FILIAL"

    If Upper(Substr(cCampoFil,1,1)) == "S"
        cCampoFil := Substr(cCampoFil,2,Len(cCampoFil))
    EndIf

    aCampos := ::GetCamposServ(::aTab[1],::cItemServ)
    If .not. Empty(aCampos[1])
        If .not. Empty(::aTab[1])
            cQuery := " SELECT " +QbLinha

            If .not. Empty(aCampos[1]) 
                If Right(aCampos[1],1) == ","
                    cQuery += Substr(aCampos[1],1,Len(aCampos[1])-1) +QbLinha
                Else 
                    cQuery += aCampos[1] +QbLinha
                EndIf
            EndIf 
            
            If .not. Empty(aCampos[2])
                If Right(aCampos[2],1) == ","
                    cQuery += ","+Substr(aCampos[2],1,Len(aCampos[2])-1) +QbLinha
                Else 
                    cQuery += ","+aCampos[2] +QbLinha
                EndIf
            EndIf 

            If Len(aCampos[3]) > 0
                For nX := 1 To Len(aCampos[3])
                    If TcGetDB() == "MSSQL"
                        cQuery += ",RTRIM(LTRIM(ISNULL(CAST(CAST("+aCampos[3][nX]+" AS VARBINARY(8000)) AS VARCHAR(8000)),''))) "+aCampos[3][nX]
                    ElseIf TcGetDB() == "ORACLE"
                        cQuery += ",TRIM(UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR("+aCampos[3][nX]+",8000))) "+aCampos[3][nX]
                    EndIf 
                Next nX
            EndIf 

            cQuery += " FROM "
            cQuery += RetSqlName(::aTab[1]) +" "+::aTab[1] +QbLinha

            If .not. Empty(aCampos[2]) 
                cQuery += cInnerJoin
            EndIf 

            cQuery += " WHERE " +QbLinha

            If ::cOper == "DELETE"
                cQuery += ::aTab[1]+".D_E_L_E_T_ <> ' ' "+QbLinha
            Else 
                cQuery += ::aTab[1]+".D_E_L_E_T_ = ' ' "+QbLinha
            EndIf

            If lFiltraFil
                cQuery += "AND " +cCampoFil+ " = '"+FWXFilial(Alltrim(::aTab[1]))+"'"+QbLinha
            EndIf

            If .not. Empty(cFiltroPK)
                cQuery += "AND " +Alltrim(cFiltroPK)+QbLinha 
            ElseIf .not. Empty(cFiltro)
                 cQuery += "AND " +Alltrim(cFiltro)+QbLinha
            EndIf

            oQuery := APIExQry():New(.F.)
            oQuery:SetQuery(cQuery)
            oQuery:SetNameJs(::aTab[1])
            oQuery:SetHasHead(.F.)

            aRet := oQuery:Execute()
            If Len(aRet) > 0
                If Upper(::cOper) <> "GET"
                    nCount := Len(aRet)
                EndIf
                cJsonRet := ::TransformArraytoJson(aRet,cNameJs,nCount,StartIndex,lGrid,aCampos[4],aCampos[5])
            Else 
                APIUtil():ConsoleLog("APIExeJS|GetJsonQuery","Registro nao encontrado pela query executada.",3)
                cMsg := "Registros nao encontrados pela consulta executada."
                ::SetRespError(500,cMsg)
                Return cJsEmpty
            EndIf
        Else 
            APIUtil():ConsoleLog("APIExeJS|GetJsonQuery","Tabela nao passada como parametro. Não será possivel retornar os dados solicitados.",4)
            cMsg := "Tabela nao passada como parametro. Não será possivel retornar os dados solicitados."
            ::SetRespError(500,cMsg)
            Return cJsonRet
        EndIf
    Else 
        APIUtil():ConsoleLog("APIExeJS|GetJsonQuery","Problema ao carregar os campos da tabela ZR1. Cadastre os campos na rotina Configurações - Api de Integração.",4)
        cMsg := "Problema ao carregar os campos da tabela ZR1. Cadastre os campos na rotina Configurações - Api de Integração."
        ::SetRespError(500,cMsg)
        Return cJsonRet
    EndIf
Return cJsonRet

/*/{Protheus.doc} SetRespError
Metodo responsavel por setar o codigo e mensagem de erro.
@type Method 
@author Ricardo Tavares Ferreira
@since 01/04/2021
@version 12.1.27
@param nCode, numeric, Código do erro para ser retornado.
@param cMsgRet, character, Mensagem a ser retornada.
@history 01/04/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Method SetRespError(nCode,cMsgRet) Class APIExeJS
//=============================================================================================================================
    ::nCode   := nCode
    ::cMsgRet := EncodeUTF8(cMsgRet)
Return

/*/{Protheus.doc} ValidaEmpresaFilial
Metodo responsavel por validar os parametros passados de Empresa e Filial.
@type Method 
@author Ricardo Tavares Ferreira
@since 30/03/2021
@version 12.1.27
@return logical, Retorna verdadeiro se validou o usuario.
@history 30/03/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Method ValidaEmpresaFilial() Class APIExeJS
//=============================================================================================================================

    Local aEmpSM0   := {}
    Local lEmp      := .F.
    Local lFil      := .F.
    Local cMsg      := ""
    Local nX        := 0

    aEmpSM0 := APIUtil():CarregaEmpresas()

    If Len(aEmpSM0) > 0
        For nX := 1 To Len(aEmpSM0)
            If Alltrim(aEmpSM0[nX][1]) == Alltrim(::cCompany)
                lEmp := .T.
            EndIf

            If Alltrim(aEmpSM0[nX][2]) == Alltrim(::cBranch)
                lFil := .T.
            EndIf
        Next nX
        If .not. lEmp .or. .not. lFil
            If .not. lEmp
                cMsg := "Empresa passada como paramentro é inválida ou não foi encontrada."
                ::SetRespError(500,cMsg)
                Return .F.
            EndIf
            If .not. lFil
                cMsg := "Filial passada como paramentro é inválida ou não foi encontrada."
                ::SetRespError(500,cMsg)
                Return .F.
            EndIf
        EndIf
    Else 
        APIUtil():ConsoleLog("APIExeJS|ValidaEmpresaFilial","Falha ao carregar as empresas da tabela SM0.",4)
    EndIf
Return .T. 

/*/{Protheus.doc} ValidaUsuario
Metodo responsavel por validar se o usuario tem acesso para executar o metodo selecionado.
@type Method 
@author Ricardo Tavares Ferreira
@since 30/03/2021
@version 12.1.27
@return logical, Retorna verdadeiro se validou o usuario.
@history 30/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
@history 12/04/2021, Ricardo Tavares Ferreira, Tratamento no retorno da tabela conforme a empresa posicionada.
/*/
//=============================================================================================================================
    Method ValidaUsuario() Class APIExeJS
//=============================================================================================================================

    Local oQuery    := Nil
    Local cCodQry 	:= "ZR0"
    Local aRet      := {}
    Local cMsg      := ""

    If .not. UsrExist(::cIdUser)
        cMsg := "O Token enviado como parametro é invalido. Usuario sem permissao ou inexitente - ID: "+ Alltrim(::cIdUser) + ". Verifique o parametro AP_USRINT."
        ::SetRespError(500,cMsg)
        Return .F.
    EndIf

    oQuery := APIExQry():New(.F.)
    oQuery:SetFormula(cCodQry)
    oQuery:SetHasHead(.F.)
    oQuery:AddFilter("TAB1", RetSqlName("ZR0"))
    oQuery:AddFilter("CFILTRO" , "ZR0_USER = '"+::cIdUser+"' AND ZR0_SERV = '"+Alltrim(::cIdServ)+"' AND ZR0_ITEM = '"+Alltrim(::cItemServ)+"'")

    aRet := oQuery:Execute()
    If Len(aRet) > 0
        APIUtil():ConsoleLog("APIExeJS|ValidaUsuario","Código de usuário "+Alltrim(::cIdUser)+" validado com sucesso.",1)
    Else 
        APIUtil():ConsoleLog("APIExeJS|ValidaUsuario","Usuário não cadastrado na tabela ZR0, para que o usuario possa utilizar a API é necessário realizar o seu cadastro. Cadastre o Serviço: "+Alltrim(::cIdServ)+" item: "+Alltrim(::cItemServ)+" para o usuario: "+::cIdUser+" para que o serviço possa ser utilizado.",4)
        cMsg := "Usuário não cadastrado na tabela ZR0, para que o usuario possa utilizar a API é necessário realizar o seu cadastro. Cadastre o Serviço: "+Alltrim(::cIdServ)+" item: "+Alltrim(::cItemServ)+" para o usuario: "+::cIdUser+" para que o serviço possa ser utilizado."
        ::SetRespError(500,cMsg)
        Return .F.
    EndIf
    FWFreeObj(oQuery)
Return .T. 

/*/{Protheus.doc} Valida
Metodo centralizador que realiza a validação de empresa Filial e usuario.
@type Method 
@author Ricardo Tavares Ferreira
@since 30/03/2021
@version 12.1.27
@return logical, Retorna verdadeiro se validou o usuario.
@history 30/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
@history 03/04/2021, Ricardo Tavares Ferreira, Incluão do Metodo que Valida a Operação executada.
/*/
//=============================================================================================================================
    Method Valida() Class APIExeJS
//=============================================================================================================================

    Local lExcValUsr := .F.

    If .not. ::ValidaEmpresaFilial()
        Return .F.
    Else 
        RpcClearEnv()
        RpcSetType(3)
        RpcSetEnv(::cCompany,::cBranch,,,,GetEnvServer(),::aTab)
    EndIf

    lExcValUsr := SuperGetMV("AP_VLDUSR",.F.,.T.)
    If lExcValUsr
        If .not. ::validaUsuario()
            Return .F.
        EndIf
        If .not. ::ValidaOperacao()
            Return .F.
        EndIf
    Else
        APIUtil():ConsoleLog("APIExeJS|Valida","Metodo Executado sem a validacao de usuario, para ativar a validacao ative o parametro - AP_VLDUSR.",1)
    EndIf
Return .T.

/*/{Protheus.doc} New
Metodo New construtor da Classe.
@type Method 
@author Ricardo Tavares Ferreira
@since 28/03/2021
@version 12.1.27
@param cIdServ, character, Id do serviço cadastrado na tabela ZR0.
@param cItemServ, character, Codigo do Item do serviço cadastrado na tabelas ZR0.
@param cIdUser, character, Codigo do Ususario.
@param cOper, character, Tipo da operação executada.
@param cCompany, character, Codigo da Empresa passado como parametro.
@param cBranch, character, Codigo da filial passada como parametro.
@param aTab, array, Array contendo as tabelas executadas neste processo.
@return object, Retorna o Objeto da Classe
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Method New(cIdServ,cItemServ,cIdUser,cOper,cCompany,cBranch,aTab,cPK) Class APIExeJS
//=============================================================================================================================
    
    Local cIdUsrInt := SuperGetMV("AP_USRINT",.F.,"")

    Default cPK := ""
    Default cIdUser := ""

    ::cIdServ   := cIdServ
    ::cItemServ := cItemServ

    If Empty(cIdUser)
        ::cIdUser   := cIdUsrInt
    Else 
        ::cIdUser   := cIdUser
    EndIf 

    ::cOper     := cOper
    ::cCompany  := cCompany
    ::cBranch   := cBranch
    ::aTab      := aTab
    ::cPK       := cPK
Return Self
