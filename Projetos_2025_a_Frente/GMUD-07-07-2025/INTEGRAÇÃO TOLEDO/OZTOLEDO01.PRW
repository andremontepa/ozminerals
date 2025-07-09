#Include "Totvs.ch"
#Include "RESTFul.ch"
#Include "TopConn.ch"
#Include "tbiconn.ch"
#define NAO_ENVIADO      	500
#define ENVIADO      		200
#define BLOQUEADO           "B"
#define ENCERRADO           "E"
#define RATEIO              "2"
#define INTEGRADO           "S"
#define PROPRIEDADE         "D"
#define PRIORIDADE          "2"
#define COD_EMPRESA         "01" 

/*/{Protheus.doc} WSRESTFUL OZTOLEDO01
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	Serviço de Post - TOLEDO
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@author JULIO MARTINS - CRMSERVICES
@since 25/01/2025
@version 1.0
@type wsrestful
/*/
WSRESTFUL OZ01TOL DESCRIPTION "Serviço de Post - TOLEDO"
	WSDATA id         AS STRING
	WSMETHOD GET    ID     DESCRIPTION "Retorna o registro pesquisado" WSSYNTAX "/OZ01TOL/get_id?{id}"  PATH "get_id"   PRODUCES APPLICATION_JSON
	WSMETHOD POST   NEW    DESCRIPTION "Inclusão de pesagem"          WSSYNTAX "/OZ01TOL/new"          PATH "new"      PRODUCES APPLICATION_JSON
END WSRESTFUL


WSMETHOD GET ID WSRECEIVE id WSSERVICE OZ01TOL
	Local lRet       := .T.
	Local jResponse  := JsonObject():New()
	Local cAliasWS   := "Z25"

	If ( Empty(::id) )
		Self:setStatus(NAO_ENVIADO)
		jResponse['errorId']     := 'ID001'
		jResponse['error']       := 'ID vazio'
		jResponse['solution']    := 'Informe o ID'
	Else
		DbSelectArea(cAliasWS)
		(cAliasWS)->(DbSetOrder(1))

		If ( ! (cAliasWS)->(MsSeek(FWxFilial(cAliasWS) + ::id)))
			Self:setStatus(NAO_ENVIADO)
			jResponse['errorId']  := 'ID002'
			jResponse['error']    := 'ID não encontrado'
			jResponse['solution'] := 'Código ID não encontrado na tabela ' + cAliasWS
		Else
			jResponse['filial']   := (cAliasWS)->C1_FILIAL
			jResponse['num']      := (cAliasWS)->C1_NUM
			jResponse['item']     := (cAliasWS)->C1_ITEM
			jResponse['produto']  := (cAliasWS)->C1_PRODUTO
			jResponse['descri ']  := (cAliasWS)->C1_DESCRI
			jResponse['um']       := (cAliasWS)->C1_UM
			jResponse['local']    := (cAliasWS)->C1_LOCAL
			jResponse['quant']    := (cAliasWS)->C1_QUANT
			jResponse['vunit']    := (cAliasWS)->C1_VUNIT
			jResponse['xpropri']  := (cAliasWS)->C1_XPROPRI
			jResponse['cc']       := (cAliasWS)->C1_CC
			jResponse['itemcta']  := (cAliasWS)->C1_ITEMCTA
			jResponse['clvl']     := (cAliasWS)->C1_CLVL
			jResponse['xpriori']  := (cAliasWS)->C1_XPRIORI
			jResponse['emissao']  := (cAliasWS)->C1_EMISSAO
			jResponse['projeto']  := (cAliasWS)->C1_XPROJET
			jResponse['tarefa']   := (cAliasWS)->C1_XTAREFA
			jResponse['obsit']    := (cAliasWS)->C1_OBS
			jResponse['dataenv']  := (cAliasWS)->C1_XDTALT
			jResponse['horaenv']  := (cAliasWS)->C1_XHRALT

		EndIf
	EndIf

	Self:SetContentType('application/json')
	Self:SetResponse(jResponse:toJSON())
Return lRet
	

WSMETHOD POST NEW WSRECEIVE WSSERVICE OZ01TOL
	Local jJson             := Nil
	Local lRet              := .T. as logical
	Local l_End             := .F. as logical
	Local jResponse         := JsonObject():New()
	Local cJson             := Self:GetContent()
	Local cDirLog           := "\toledo_logs\" as character
	Local cError            := ""  as character
	Local cEmpBkp 			:= ""  as character
	Local cFilBkp 			:= ""  as character
	Local cNumEmpBkp        := ""  as character
	Local cCnpj             := ""  as character  // Cnpj Enviado
	Local cProdu            := ""  as character  // Produto a ser utilizado
	Local cTes              := ""  as character  // Código da TES 
	Local cClient           := ""  as character  // Código do Cliente
	Local cLoja             := ""  as character  // Loja do Cliente
	Local cTransp           := ""  as character  // Código Transportadora
	Local cTabela           := ""  as character  // Código Tabela de Preços
	Local cMoeda            := ""  as character  // Codigo Moeda
	Local cDesc             := ""  as character  // Descrição do Produto
	Local aChave            := ""  as character  // Chave Nfe
	Local cNotafi			:= space(9)          // Nº Nfe gerada
	Local cSer              := ""  as character  // Série NFe Saida
	Local c_Alias           := "SF2"
	Local nPbruto			:= 0                 // Peso Bruto
	Local nPliqui           := 0                 // Peso Liquido
	Local nQuant			:= 0				 // Quantidade
	Local nPreco			:= 0        		 // Preço Unitário
	Local cTime             := Time() 
	Local aArea             := {}  as array
	Private lMsErroAuto     := .F. as logical
	Private lMsHelpAuto     := .T. as logical
	Private lAutoErrNoFile  := .T. as logical

	Self:SetContentType('application/json')
	jJson      := JsonObject():New()
	cError     := jJson:FromJson(cJson)
	aArea      := GetArea()
	cEmpBkp    := cEmpAnt
	cFilBkp    := cFilAnt
	cNumEmpBkp := cNumEmp
	cEmpAnt    := "01" // AVB Mineração 
	cNumEmp    := cEmpAnt + cFilAnt
	cCnpj      := Alltrim(jJson:GetJsonObject("empresa"))
	cTime := substring(cTime,1,2)+substring(cTime,4,2)+substring(cTime,7,2)

	IF ! ExistDir(cDirLog)
		MakeDir(cDirLog) 
	EndIF

	// 01/02 - Antas = Filial 02 AVB MINERAÇÃO = FILIAL CURIONOPOLIS
	// Cnpj : 07605563000586
	// Codigo : 000009 / 01
	// Destino: 000127 / 01
	// cProdu = 12200
	// cTes   =
	// 01/06 - Pedra Branca = Filial 06 AVB MINERAÇÃO = FILIAL AGUA AZUL DO NORTE
	// Cnpj : 07605563000748
	// Codigo : 000127 / 01
	// Destino: 000009 / 01
    // cProdu = 014983
    // cTes   = 

	//cA1Cod     := SUBSTRING(SUPERGETMV("OZ_CLIEXP"),1,6)    // Código do Cliente
	//cA1Loja    := SUBSTRING(SUPERGETMV("OZ_CLIEXP"),7,2)  

	if cCnpj="07605563000586"  // Produto -> Antas
	cEmpAnt:= "01"
	cFilAnt:= "02"
	cProdu := "12200"
	cDesc  := Posicione("SB1",1,xFilial("SB1") + cProdu,"B1_DESC")
	cTes   := "501"
	cSer   := "1"
	cTransp:= "000045"
	cClient:= "000127"
	cLoja  := "01"
	nPreco := 14.7319
    endif

	if cCnpj="07605563000748"   // Produto -> Pedra Branca
	cEmpAnt:= "01"
	cFilAnt:= "06"
	cProdu := "014983"
	cDesc  := Posicione("SB1",1,xFilial("SB1") + cProdu,"B1_DESC")
	cTes   := "501"
	cSer   := "1"
	cTransp:= "000045"
	cClient:= "000009"
	cLoja  := "01"
	nPreco := 16.2578
    endif
	
    TOfechasx()  // Fecha empresa acessada
	TOAbreEmp()  // Abre empresa acessada


		//Verificar Cpf
		//Verificar Cnpj

		If (!Empty (cError))
		Self:setStatus(NAO_ENVIADO)
		jResponse['errorId']  := 'NEW001'
		jResponse['error']    := 'Parse do JSON'
		jResponse['solution'] := 'Erro ao fazer o Parse do JSON'
		Else
		//#######################################//
		// Grava Movimento Monitor de Integração //
		//#######################################//

			DbSelectArea("Z25")
			DbSetOrder(1)
			RecLock("Z25", .T.)
			Z25->Z25_FILIAL := cFilAnt
			Z25->Z25_DATA   := DDATABASE
			Z25->Z25_HORA   := Time()
			Z25->Z25_CNPJ   := cCnpj     // Cnpj Origem
			Z25->Z25_PRODUT := cProdu    // Codigo do Produto
			Z25->Z25_CLIENT := cClient   // Codigo Cliente Destino
			Z25->Z25_LOJA   := cLoja     // Loja Cliente
			Z25->Z25_PLACAR := Alltrim(jJson:GetJsonObject("placacar"))   // Placa da Carreta
			Z25->Z25_PLACAV := Alltrim(jJson:GetJsonObject("placavei"))   // Placa do Veiculo
			Z25->Z25_MOTOR  := Alltrim(jJson:GetJsonObject("nomemoto"))   // Nome do Motorista
			Z25->Z25_CPFMO  := Alltrim(jJson:GetJsonObject("cpfmotor"))   // Cpf do Motorista
			Z25->Z25_PESOBR := jJson:GetJsonObject("pesobrut")   // Peso Bruto
			Z25->Z25_PESOLI := jJson:GetJsonObject("pesoliqu")   // Peso Liquido
			Z25->Z25_PESOTA := jJson:GetJsonObject("pesotara")   // Peso Tara
			Z25->( MsUnlock() )
		
				//#######################//
				// Gera Pedido de Vendas //
				//#######################//

				nPbruto := jJson:GetJsonObject("pesobrut")
				nPliqui := jJson:GetJsonObject("pesoliqu")
				nQuant  := jJson:GetJsonObject("pesoliqu")

				lRet:=U_OZGERAPED(cClient, cLoja ,cTransp, cTabela,cMoeda,nPbruto,nPliqui,cProdu,cDesc,nQuant,nPreco,aChave)
				

				if lRet 
								//##################//
				// Gera Nota Fiscal //
				//##################//
				cNotafi:=U_OZGERANOTA(cPedido,cSer,cProdu,cClient,cLoja,nQuant,nPreco)

				//####################################//
				// Retorna Post Sucesso Pedido Vendas //	
				//####################################//
				//Self:setStatus(ENVIADO)
				//jResponse['note']     := "Nota Fiscal:"+cNotafi+" Gerada com sucesso"
				//jResponse['empresa']  := Alltrim(jJson:GetJsonObject("empresa"))
				//jResponse['nomemoto'] := Alltrim(jJson:GetJsonObject("nomemoto")) 
				//jResponse['cpfmoto']  := Alltrim(jJson:GetJsonObject("cpfmoto")) 
				//jResponse['placacar'] := Alltrim(jJson:GetJsonObject("placacar")) 
				//jResponse['placavei'] := Alltrim(jJson:GetJsonObject("placavei")) 
				

				lRet := .T.
				
				//##################//			
				// Transmite a Nfe  //
				//##################//
				lRet:=U_OZTRANSMITE(c_Alias,cSer,cNotafi,cNotafi,l_End)

				if lRet
				Self:setStatus(ENVIADO)
				jResponse['note']     := "Nota Fiscal:"+cNotafi+" Transmitida com sucesso"
				else
				lRet := .F.
				jResponse['note']     := "NOTA FISCAL GERADA:"+cNotafi+" -->> PROBLEMAS NA TRANSMISSÃO, VERIFIQUE!!"
				Endif

			//	if l_End =.F.
			//	DbSelectArea("Z25")
			//	RecLock( "Z25", .F. )
			//	Z25->Z25_STATUS:= "Erro transmissão Nfe verificar Log."
			//	Z25->( MsUnlock() )
			//	Else
				Else
				//#######################//
				// Retorna Post Problema //	
				//#######################//
				Self:setStatus(ENVIADO)
				jResponse['note']     := "Problema na Integracao verificar log -> \_toledo\"
				jResponse['empresa']  := Alltrim(jJson:GetJsonObject("empresa"))
				lRet                  := .F.
				Endif
				
		Endif
		Self:SetResponse(jResponse:toJSON())
RestArea(aArea)
Return lRet


***************************
Static function TOAbreEmp()
***************************
cNumEmp := cEmpAnt+cFilAnt
Opensm0(cNumEmp)
Openfile(cNumEmp)
return NIL

****************************
Static function TOFechaSX()
****************************
Local nX
     if Select("XXS") > 0 ; XXS->(dbCloseArea()) ; endif
     if Select("XB3") > 0 ; XB3->(dbCloseArea()) ; endif
     if Select("SIX") > 0 ; SIX->(dbCloseArea()) ; endif
     if Select("XAB") > 0 ; XAB->(dbCloseArea()) ; endif
     if Select("XAL") > 0 ; XAL->(dbCloseArea()) ; endif
     if Select("XAM") > 0 ; XAM->(dbCloseArea()) ; endif
     if Select("XAN") > 0 ; XAN->(dbCloseArea()) ; endif
     if Select("XAO") > 0 ; XAO->(dbCloseArea()) ; endif
     if Select("XAP") > 0 ; XAP->(dbCloseArea()) ; endif
     if Select("XAS") > 0 ; XAS->(dbCloseArea()) ; endif
     cAlias := "SX0"              // fecha todos os SXs
     for nX := 1 to 40
        if (Select(cAlias)>0)
           (cAlias)->(dbCloseArea())
        endif     
        cAlias := soma1(cAlias)
     next
     cAlias := "XX1"             // fecha todos os XXs
     for nX := 1 to 40
        if (Select(cAlias)>0)
           (cAlias)->(dbCloseArea())
        endif     
        cAlias := soma1(cAlias)
     next
return NIL
