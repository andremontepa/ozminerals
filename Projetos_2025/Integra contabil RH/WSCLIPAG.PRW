#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://10.106.10.20:8082/WSPAGAMENTOS.apw?WSDL
Gerado em        08/31/19 19:34:25
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _TNLSJXG ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWSPAGAMENTOS
------------------------------------------------------------------------------- */

WSCLIENT WSWSPAGAMENTOS

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GETPAGAMENTOS
	WSMETHOD POSTPAGAMENTOS

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cFILIALINICIAL            AS string
	WSDATA   cFILIALFINAL              AS string
	WSDATA   cPREFIXOINICIAL           AS string
	WSDATA   cPREFIXOFINAL             AS string
	WSDATA   cTITULOINICIAL            AS string
	WSDATA   cTITULOFINAL              AS string
	WSDATA   cFORNECINICIAL            AS string
	WSDATA   cFORNECFINAL              AS string
	WSDATA   cLOJAINICIAL              AS string
	WSDATA   cLOJAFINAL                AS string
	WSDATA   oWSGETPAGAMENTOSRESULT    AS WSPAGAMENTOS_PAGAMENTOS
	WSDATA   oWSPOSTPAGAMENTOSLOTE     AS WSPAGAMENTOS_PAGAMENTOS
	WSDATA   cPOSTPAGAMENTOSRESULT     AS string

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSPAGAMENTOS             AS WSPAGAMENTOS_PAGAMENTOS

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWSPAGAMENTOS
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20171213 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWSPAGAMENTOS
	::oWSGETPAGAMENTOSRESULT := WSPAGAMENTOS_PAGAMENTOS():New()
	::oWSPOSTPAGAMENTOSLOTE := WSPAGAMENTOS_PAGAMENTOS():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSPAGAMENTOS      := ::oWSPOSTPAGAMENTOSLOTE
Return

WSMETHOD RESET WSCLIENT WSWSPAGAMENTOS
	::cFILIALINICIAL     := NIL 
	::cFILIALFINAL       := NIL 
	::cPREFIXOINICIAL    := NIL 
	::cPREFIXOFINAL      := NIL 
	::cTITULOINICIAL     := NIL 
	::cTITULOFINAL       := NIL 
	::cFORNECINICIAL     := NIL 
	::cFORNECFINAL       := NIL 
	::cLOJAINICIAL       := NIL 
	::cLOJAFINAL         := NIL 
	::oWSGETPAGAMENTOSRESULT := NIL 
	::oWSPOSTPAGAMENTOSLOTE := NIL 
	::cPOSTPAGAMENTOSRESULT := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSPAGAMENTOS      := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWSPAGAMENTOS
Local oClone := WSWSPAGAMENTOS():New()
	oClone:_URL          := ::_URL 
	oClone:cFILIALINICIAL := ::cFILIALINICIAL
	oClone:cFILIALFINAL  := ::cFILIALFINAL
	oClone:cPREFIXOINICIAL := ::cPREFIXOINICIAL
	oClone:cPREFIXOFINAL := ::cPREFIXOFINAL
	oClone:cTITULOINICIAL := ::cTITULOINICIAL
	oClone:cTITULOFINAL  := ::cTITULOFINAL
	oClone:cFORNECINICIAL := ::cFORNECINICIAL
	oClone:cFORNECFINAL  := ::cFORNECFINAL
	oClone:cLOJAINICIAL  := ::cLOJAINICIAL
	oClone:cLOJAFINAL    := ::cLOJAFINAL
	oClone:oWSGETPAGAMENTOSRESULT :=  IIF(::oWSGETPAGAMENTOSRESULT = NIL , NIL ,::oWSGETPAGAMENTOSRESULT:Clone() )
	oClone:oWSPOSTPAGAMENTOSLOTE :=  IIF(::oWSPOSTPAGAMENTOSLOTE = NIL , NIL ,::oWSPOSTPAGAMENTOSLOTE:Clone() )
	oClone:cPOSTPAGAMENTOSRESULT := ::cPOSTPAGAMENTOSRESULT

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSPAGAMENTOS := oClone:oWSPOSTPAGAMENTOSLOTE
Return oClone

// WSDL Method GETPAGAMENTOS of Service WSWSPAGAMENTOS

WSMETHOD GETPAGAMENTOS WSSEND cFILIALINICIAL,cFILIALFINAL,cPREFIXOINICIAL,cPREFIXOFINAL,cTITULOINICIAL,cTITULOFINAL,cFORNECINICIAL,cFORNECFINAL,cLOJAINICIAL,cLOJAFINAL WSRECEIVE oWSGETPAGAMENTOSRESULT WSCLIENT WSWSPAGAMENTOS
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETPAGAMENTOS xmlns="http://10.106.10.20:8082/">'
cSoap += WSSoapValue("FILIALINICIAL", ::cFILIALINICIAL, cFILIALINICIAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILIALFINAL", ::cFILIALFINAL, cFILIALFINAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PREFIXOINICIAL", ::cPREFIXOINICIAL, cPREFIXOINICIAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PREFIXOFINAL", ::cPREFIXOFINAL, cPREFIXOFINAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TITULOINICIAL", ::cTITULOINICIAL, cTITULOINICIAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TITULOFINAL", ::cTITULOFINAL, cTITULOFINAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FORNECINICIAL", ::cFORNECINICIAL, cFORNECINICIAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FORNECFINAL", ::cFORNECFINAL, cFORNECFINAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LOJAINICIAL", ::cLOJAINICIAL, cLOJAINICIAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LOJAFINAL", ::cLOJAFINAL, cLOJAFINAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GETPAGAMENTOS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://10.106.10.20:8082/GETPAGAMENTOS",; 
	"DOCUMENT","http://10.106.10.20:8082/",,"1.031217",; 
	"http://10.106.10.20:8082/WSPAGAMENTOS.apw")

::Init()
::oWSGETPAGAMENTOSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETPAGAMENTOSRESPONSE:_GETPAGAMENTOSRESULT","PAGAMENTOS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method POSTPAGAMENTOS of Service WSWSPAGAMENTOS

WSMETHOD POSTPAGAMENTOS WSSEND oWSPOSTPAGAMENTOSLOTE WSRECEIVE cPOSTPAGAMENTOSRESULT WSCLIENT WSWSPAGAMENTOS
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<POSTPAGAMENTOS xmlns="http://10.106.10.20:8082/">'
cSoap += WSSoapValue("POSTPAGAMENTOSLOTE", ::oWSPOSTPAGAMENTOSLOTE, oWSPOSTPAGAMENTOSLOTE , "PAGAMENTOS", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</POSTPAGAMENTOS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://10.106.10.20:8082/POSTPAGAMENTOS",; 
	"DOCUMENT","http://10.106.10.20:8082/",,"1.031217",; 
	"http://10.106.10.20:8082/WSPAGAMENTOS.apw")

::Init()
::cPOSTPAGAMENTOSRESULT :=  WSAdvValue( oXmlRet,"_POSTPAGAMENTOSRESPONSE:_POSTPAGAMENTOSRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure PAGAMENTOS

WSSTRUCT WSPAGAMENTOS_PAGAMENTOS
	WSDATA   oWSPAGAMENTOSLOTE         AS WSPAGAMENTOS_ARRAYOFPAGAMENTO
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSPAGAMENTOS_PAGAMENTOS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSPAGAMENTOS_PAGAMENTOS
Return

WSMETHOD CLONE WSCLIENT WSPAGAMENTOS_PAGAMENTOS
	Local oClone := WSPAGAMENTOS_PAGAMENTOS():NEW()
	oClone:oWSPAGAMENTOSLOTE    := IIF(::oWSPAGAMENTOSLOTE = NIL , NIL , ::oWSPAGAMENTOSLOTE:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSPAGAMENTOS_PAGAMENTOS
	Local cSoap := ""
	cSoap += WSSoapValue("PAGAMENTOSLOTE", ::oWSPAGAMENTOSLOTE, ::oWSPAGAMENTOSLOTE , "ARRAYOFPAGAMENTO", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSPAGAMENTOS_PAGAMENTOS
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_PAGAMENTOSLOTE","ARRAYOFPAGAMENTO",NIL,"Property oWSPAGAMENTOSLOTE as s0:ARRAYOFPAGAMENTO on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSPAGAMENTOSLOTE := WSPAGAMENTOS_ARRAYOFPAGAMENTO():New()
		::oWSPAGAMENTOSLOTE:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure ARRAYOFPAGAMENTO

WSSTRUCT WSPAGAMENTOS_ARRAYOFPAGAMENTO
	WSDATA   oWSPAGAMENTO              AS WSPAGAMENTOS_PAGAMENTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSPAGAMENTOS_ARRAYOFPAGAMENTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSPAGAMENTOS_ARRAYOFPAGAMENTO
	::oWSPAGAMENTO         := {} // Array Of  WSPAGAMENTOS_PAGAMENTO():New()
Return

WSMETHOD CLONE WSCLIENT WSPAGAMENTOS_ARRAYOFPAGAMENTO
	Local oClone := WSPAGAMENTOS_ARRAYOFPAGAMENTO():NEW()
	oClone:oWSPAGAMENTO := NIL
	If ::oWSPAGAMENTO <> NIL 
		oClone:oWSPAGAMENTO := {}
		aEval( ::oWSPAGAMENTO , { |x| aadd( oClone:oWSPAGAMENTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSPAGAMENTOS_ARRAYOFPAGAMENTO
	Local cSoap := ""
	aEval( ::oWSPAGAMENTO , {|x| cSoap := cSoap  +  WSSoapValue("PAGAMENTO", x , x , "PAGAMENTO", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSPAGAMENTOS_ARRAYOFPAGAMENTO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_PAGAMENTO","PAGAMENTO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSPAGAMENTO , WSPAGAMENTOS_PAGAMENTO():New() )
			::oWSPAGAMENTO[len(::oWSPAGAMENTO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure PAGAMENTO

WSSTRUCT WSPAGAMENTOS_PAGAMENTO
	WSDATA   cCENTROCUSTO              AS string
	WSDATA   cDATACONTABIL             AS string
	WSDATA   cDATAEMISSAO              AS string
	WSDATA   cFILIAL                   AS string
	WSDATA   cFORNECEDOR               AS string
	WSDATA   cHISTORICO                AS string
	WSDATA   cITEMCONTABIL             AS string
	WSDATA   cLOJA                     AS string
	WSDATA   cNATUREZA                 AS string
	WSDATA   cNOMEFORNECE              AS string
	WSDATA   cNUMTITULO                AS string
	WSDATA   cPARCELA                  AS string
	WSDATA   cPREFIXO                  AS string
	WSDATA   cTIPO                     AS string
	WSDATA   nVALORTOTAL               AS float
	WSDATA   cVENCIMENTO               AS string
	WSDATA   cVENCREAL                 AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSPAGAMENTOS_PAGAMENTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSPAGAMENTOS_PAGAMENTO
Return

WSMETHOD CLONE WSCLIENT WSPAGAMENTOS_PAGAMENTO
	Local oClone := WSPAGAMENTOS_PAGAMENTO():NEW()
	oClone:cCENTROCUSTO         := ::cCENTROCUSTO
	oClone:cDATACONTABIL        := ::cDATACONTABIL
	oClone:cDATAEMISSAO         := ::cDATAEMISSAO
	oClone:cFILIAL              := ::cFILIAL
	oClone:cFORNECEDOR          := ::cFORNECEDOR
	oClone:cHISTORICO           := ::cHISTORICO
	oClone:cITEMCONTABIL        := ::cITEMCONTABIL
	oClone:cLOJA                := ::cLOJA
	oClone:cNATUREZA            := ::cNATUREZA
	oClone:cNOMEFORNECE         := ::cNOMEFORNECE
	oClone:cNUMTITULO           := ::cNUMTITULO
	oClone:cPARCELA             := ::cPARCELA
	oClone:cPREFIXO             := ::cPREFIXO
	oClone:cTIPO                := ::cTIPO
	oClone:nVALORTOTAL          := ::nVALORTOTAL
	oClone:cVENCIMENTO          := ::cVENCIMENTO
	oClone:cVENCREAL            := ::cVENCREAL
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSPAGAMENTOS_PAGAMENTO
	Local cSoap := ""
	cSoap += WSSoapValue("CENTROCUSTO", ::cCENTROCUSTO, ::cCENTROCUSTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DATACONTABIL", ::cDATACONTABIL, ::cDATACONTABIL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DATAEMISSAO", ::cDATAEMISSAO, ::cDATAEMISSAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FILIAL", ::cFILIAL, ::cFILIAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FORNECEDOR", ::cFORNECEDOR, ::cFORNECEDOR , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("HISTORICO", ::cHISTORICO, ::cHISTORICO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ITEMCONTABIL", ::cITEMCONTABIL, ::cITEMCONTABIL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("LOJA", ::cLOJA, ::cLOJA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NATUREZA", ::cNATUREZA, ::cNATUREZA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NOMEFORNECE", ::cNOMEFORNECE, ::cNOMEFORNECE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NUMTITULO", ::cNUMTITULO, ::cNUMTITULO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PARCELA", ::cPARCELA, ::cPARCELA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PREFIXO", ::cPREFIXO, ::cPREFIXO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TIPO", ::cTIPO, ::cTIPO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VALORTOTAL", ::nVALORTOTAL, ::nVALORTOTAL , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VENCIMENTO", ::cVENCIMENTO, ::cVENCIMENTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VENCREAL", ::cVENCREAL, ::cVENCREAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSPAGAMENTOS_PAGAMENTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCENTROCUSTO       :=  WSAdvValue( oResponse,"_CENTROCUSTO","string",NIL,"Property cCENTROCUSTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDATACONTABIL      :=  WSAdvValue( oResponse,"_DATACONTABIL","string",NIL,"Property cDATACONTABIL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDATAEMISSAO       :=  WSAdvValue( oResponse,"_DATAEMISSAO","string",NIL,"Property cDATAEMISSAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFILIAL            :=  WSAdvValue( oResponse,"_FILIAL","string",NIL,"Property cFILIAL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFORNECEDOR        :=  WSAdvValue( oResponse,"_FORNECEDOR","string",NIL,"Property cFORNECEDOR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cHISTORICO         :=  WSAdvValue( oResponse,"_HISTORICO","string",NIL,"Property cHISTORICO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cITEMCONTABIL      :=  WSAdvValue( oResponse,"_ITEMCONTABIL","string",NIL,"Property cITEMCONTABIL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cLOJA              :=  WSAdvValue( oResponse,"_LOJA","string",NIL,"Property cLOJA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNATUREZA          :=  WSAdvValue( oResponse,"_NATUREZA","string",NIL,"Property cNATUREZA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNOMEFORNECE       :=  WSAdvValue( oResponse,"_NOMEFORNECE","string",NIL,"Property cNOMEFORNECE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNUMTITULO         :=  WSAdvValue( oResponse,"_NUMTITULO","string",NIL,"Property cNUMTITULO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPARCELA           :=  WSAdvValue( oResponse,"_PARCELA","string",NIL,"Property cPARCELA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPREFIXO           :=  WSAdvValue( oResponse,"_PREFIXO","string",NIL,"Property cPREFIXO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTIPO              :=  WSAdvValue( oResponse,"_TIPO","string",NIL,"Property cTIPO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nVALORTOTAL        :=  WSAdvValue( oResponse,"_VALORTOTAL","float",NIL,"Property nVALORTOTAL as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cVENCIMENTO        :=  WSAdvValue( oResponse,"_VENCIMENTO","string",NIL,"Property cVENCIMENTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cVENCREAL          :=  WSAdvValue( oResponse,"_VENCREAL","string",NIL,"Property cVENCREAL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


