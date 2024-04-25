#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATA002  ºAutor  ³Alisson Alessandro	 º Data ³  01/01/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tela de consulta especifica de produtos com informacoes de  º±±
±±º          ³estoque, preço e foto.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±   
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Parametro: MV_RFDESC = B1_DESC/B1_ESPECIF					Release: 12.1.4
Parametro: MV_RFPERS = B1_GRTRIB/B1_YREF
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ESTC001(_cCodProd)

Local _cQuery   := ""
Local _nAlias   := ""
Local _cChave   := Space(50)
Local _cDesc	:= Space(50)
Local _cChvGr	:= Space(4) //chave para grupo produto
Local _cChvSub	:= Space(3) 
Local _cChvCla	:= Space(3)
Local _cChvFab	:= Space(15)
Local _nAux     := 0
Local _aTitulos := {}
Local i := 0
private nPos:=1
Private _cFiliais := ''
Private _cRet   := ""
Private _oDlg
Private _oBar
Private _oLbl1
Private _oLbl2
Private _oLbl3
Private _oLbl4
Private _oSldB2
Private _oSay
Private _oSay11
Private _oSay12
Private _oSay21
Private _oSay22
Private _oSay31
Private _oSay32
Private _oSay41
Private _oSay42
Private _oSay51
Private _oSay52
Private _oSay61
Private _oSay62
Private _oSay63
Private _oSay71
Private _oSay72
Private _oSay81
Private _oSay82
Private _oFonte1
Private _nSld1    := 0
Private _nSld2    := 0
Private _nSld3    := 0
Private _nSld4    := 0
Private _nPrcVnd  := 0
Private _nDescon  := 0
Private _nPrcFab  := 0
Private _nPrcMax  := 0
Private _cTitulo  := "Consulta de produtos"
Private _aLegenda := {}
Private _aFiliais := {}
Private _aSldB2   := {}
Private _aSldFil  := {}
Private _aProduto := {}
Private _aPreco		:={}
Private nAcrecimo  := 1
Private aAreaSE4 := SEa->(GetArea())
//Private _aNotas		:={}
Private _aItens		:={}
Private _oChave
Private _oDesc
Private oBut2
//Private oProd	:= SLR->LR_PRODUTO
Private _nEmpAtu := 0 
Private lCheck1  := .F.       
Private cDesc :=  SuperGetMv( "MV_RFDESC" , .F. , "B1_DESC" , )
Private cPers :=  SuperGetMv( "MV_RFPERS" , .F. , "B1_GRTRIB" , )
Private cCgc  :=  SuperGetMv( "MV_CGC" , .F. , " " , )
Private cTitDesc 
//aArray:={"Descrição","Codigo","Codigo de Barras"}

Private oFont10  := TFont():New('Arial',,10,,.F.,,,,.F.,.F.)
Private oFont13  := TFont():New('Arial',,13,,.T.,,,,.F.,.F.)
Private oFont14  := TFont():New('Arial',,14,,.F.,,,,.F.,.F.)
Private oFont16n := TFont():New('Arial',,16,,.T.,,,,.F.,.F.)

//Alert(_cCodProd)

//valida CNPJ do cliente para acesso a rotina
//valida CNPJ do cliente para acesso a rotina
//If SM0->M0_CGC != cCgc   
//	MsgStop("Empresa não autorizada para uso da rotina!!!")
//	return(.F.)
//Endif 

If cDesc = "B1_DESC"       //mudando o titulo do campo descricao no browse de acordo com o parametro da desc. utilizada
	cTitDesc := "Descrição"
Else
	cTitDesc := "Descrição Especif."
Endif                             
If cPers = "B1_GRTRIB"       //mudando o titulo do campo descricao no browse de acordo com o parametro da desc. utilizada
	cTitPers := "Grupo Trib."
Else
	cTitPers := "Referencia"
Endif                             
aArray:={"Fabricante",cTitDesc,"Codigo","Cod. Barras  ","Marca"}

if Empty(mv_par60)
	mv_par60 := PADR("SERV",50, " ")
endif

_cDesc := mv_par60

If UPPER(alltrim(funname())) <> "RESTC001"
	Default _cCodProd := &(ReadVar())
EndIf

// Cria a fonte para ser usada na montagenm da tela
_oFonte1  := TFont():New( "Arial",,14,,.T.)

dbSelectArea("DA1")
dbSetOrder(2)

// Cria um array com as filiais
dbSelectArea("SM0")
SM0->( dbGoTop() )
_nEmpAtu := Recno()

While SM0->(!EOF())
	aAdd(_aFiliais,{SM0->M0_CODFIL,SM0->M0_FILIAL})
	SM0->(dbSkip())
EndDo

//--------------------- Atualizacao feita por Fernando Vallim para agilizar as consultas aninhadas (Melhorar o CUSTO de excecucao do SQL - 24/11/10)
_cFiliais := ''
for i := 1 to len(_aFiliais)
	_cFiliais += "'"+_aFiliais[i,1]+"'"
	if i < len(_aFiliais)
		_cFiliais += ','
	endif
next i
//----------------------------------------------------------------------------------------------------------------------------------------------------

SM0->(dbSeek(cEmpAnt+cFilAnt))
//alert(len(_aFiliais))
// Adiciona as opcoes de legenda do programa
AAdd(_aLegenda, {"BR_VERDE","Alto Giro"} )
AAdd(_aLegenda, {"BR_AMARELO","Médio Giro"} )
AAdd(_aLegenda, {"BR_LARANJA","Baixo Giro"} )
AAdd(_aLegenda, {"BR_PRETO","Produto Novo"} )
AAdd(_aLegenda, {"BR_VERMELHO","Sem Giro"} )
aBUTTONS := {}

AADD(aBUTTONS,{"S4WB010N",	{||U_ESPECIF_PROD(_aProduto[_oListBox:nAT][02])}, "Especificação","Especificação"})

// Cria a tela principal
DEFINE MSDIALOG _oDlg TITLE _cTitulo FROM 0,0 TO 530,1000 OF GetWndDefault() PIXEL
oGroup:= TGroup():New(33,04,080,500,,_oDlg,,,.T.)
@034,010 RADIO aArray VAR nPos Object oRdx  
oSay  := TSay():New(060,088, {|| 'Filtro.[F12] '},_oDlg,,oFont14,,,,.T.,CLR_BLACK,)
oGet1 := TGet():New(067,088,{|u|iif(PCount()==0,_cDesc,_cDesc:=u)},oGroup,150,10,"@!",,0,,,.F.,,.T.,,.F.,{||},.F.,.F.,{||},.F.,.F.,,_cDesc,,,, )   
oBtn1 := TButton():New(65,240,"Pesquisar",oGroup,{||_oPesqSB1(_cChave,_cChvGr,_cChvSub,_cChvCla,_cDesc,_cChvFab)},037,012,,,,.T.,,"",,,,.F. )

//Função que checa a tecla pressionada e executa tarefas
//SetKey( VK_F12, { || MsgAlert("AFA010") } )
//SetKey( VK_F1, { || oRdx:SetFocus() } )
SetKey( VK_F12, { || oGet1:SetFocus() } )
oGet1:SetFocus()

// Desabilita as teclas F4, F5, F6, F7 na tela de vendas
//LjTeclas( .F., .F., .F., .F. )

// Cria listbox com os dados dos produtos conforme a tabela temporaria criada 
IF CNIVEL > 5
	AAdd(_aProduto, {"","","","","","","","","","","","",""} )
	AAdd(_aTitulos, {"","Codigo",cTitDesc,"Tipo","UM","Preço","Custo","Estoque", "Fabricante",cTitPers,"Cod.Barras"})
	AAdd(_aTitulos, {10,50,100,20,20,30,30,30,35,50})
ELSE
	AAdd(_aProduto, {"","","","","","","","","","","",""} )
	AAdd(_aTitulos, {"","Codigo",cTitDesc,"Tipo","UM","Preço","Estoque", "Fabricante",cTitPers,"Cod.Barras"})
	AAdd(_aTitulos, {10,50,100,20,20,30,30,35,50})
ENDIF

_oListBox := TWBrowse():New(083,001,500,100,,_aTitulos[1],_aTitulos[2],_oDlg,,,,,,,,,,,,.F.,,.T.,,.F.) 
_oListBox:bChange    := {|| _oChgProd("T", xFilial("SB2")) }
_oListBox:blDblClick := {|| PosProd(_aProduto[_oListBox:nAT][02] ), _oDlg:End() }

_oListBox:SetArray(_aProduto)

IF CNIVEL > 5
_oListBox:bLine := { || { LoadBitmap(GetResources()    ,;
                          _aProduto[_oListBox:nAT][01]),;
                          _aProduto[_oListBox:nAT][02] ,;
                          _aProduto[_oListBox:nAT][03] ,;
                          _aProduto[_oListBox:nAT][04] ,;
                          _aProduto[_oListBox:nAT][05] ,;
                          _aProduto[_oListBox:nAT][06] ,;
                          _aProduto[_oListBox:nAT][07] ,;
                          _aProduto[_oListBox:nAT][08] ,;
                          _aProduto[_oListBox:nAT][09] ,;
						  _aProduto[_oListBox:nAT][10], ;
						  _aProduto[_oListBox:nAT][11] } }
ELSE
_oListBox:bLine := { || { LoadBitmap(GetResources()    ,;
                          _aProduto[_oListBox:nAT][01]),;
                          _aProduto[_oListBox:nAT][02] ,;
                          _aProduto[_oListBox:nAT][03] ,;
                          _aProduto[_oListBox:nAT][04] ,;
                          _aProduto[_oListBox:nAT][05] ,;
                          _aProduto[_oListBox:nAT][06] ,;
                          _aProduto[_oListBox:nAT][07] ,;
                          _aProduto[_oListBox:nAT][08] ,;
                          _aProduto[_oListBox:nAT][09] ,;
						  _aProduto[_oListBox:nAT][10] } }
ENDIF                                                   

//oCheck1 := TCheckBox():New(55,400,"Mostrar produtos sem estoque",,_oDlg,100,300,,,,,,,,.T.,,,)
oBtn1 := TButton():New(67,460,"Tab.Preco",oGroup,{||TabPrecos(_aProduto[_oListBox:nAT][02])},037,012,,,,.T.,,"",,,,.F. )
oCheck1 := TCheckBox():New(33,410,"Mostrar produtos sem estoque",,_oDlg,100,300,,,,,,,,.T.,,,)
oCheck1:bSetGet := {|| lCheck1 }
oCheck1:bLClicked := {|| lCheck1:=!lCheck1 }
oCheck1:bWhen := {|| .T. }                                      

AAdd(_aSldB2, {"", Transform(0,"@E 999,999.99")} )
AAdd(_aPreco, {"", Transform(0,"@E 999,999.99"), Transform(0,"@E 999,999.99"), Transform(0,"@E 999,999.99"), Transform(0,"@E 999,999.99")} )

_oLbl1  := tGroup():New(185,002,258,355,"ESTOQUE POR FILIAL",_oDlg,,,.T.)
_oSldFil := TWBrowse():New(193,003,350,060,,{"Filial","Armazem","Qtde. Atual","Qtde. Disponível","Reservado","Qtde. Prevista"},{10,50,50},_oLbl1,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
_oSldFil:SetArray(_aSldFil)
_oSldFil:bLine := { || { _aSldFil[_oSldFil:nAt][1], _aSldFil[_oSldFil:nAt][2], _aSldFil[_oSldFil:nAt][3],_aSldFil[_oSldFil:nAt][4],_aSldFil[_oSldFil:nAt][5],_aSldFil[_oSldFil:nAt][6] } }

//Jerry
//IMAGEM
_oLbl4  := tGroup():New(185,360,258,495,"IMAGEM",_oDlg,,,.T.)
oTBitmap2 := TBitmap():Create(_oDlg,194,365,120,090,,,.T.,;
		             {||U_ESPECIF_PROD(_aProduto[_oListBox:nAT][02])},,.F.,.F.,,,.F.,,.T.,,.F.)
oTBitmap2:lAutoSize := .T.         

/*If _cCodProd <> Nil
	If !Empty(_cCodProd)
		_oPesqSB1(_cCodProd)
	EndIf
EndIf*/

if !Empty(mv_par60)
	Processa({|| _oPesqSB1(_cChave,_cChvGr,_cChvSub,_cChvCla,_cDesc,_cChvFab)},"Pesquisando produto...")
endif

//ACTIVATE MSDIALOG _oDlg CENTER
ACTIVATE MsDIALOG _oDlg ON INIT ENCHOICEBAR(_oDlg,{|| PosProd(_aProduto[_oListBox:nAT][02]),_oDlg:END()},{|| IIF(Empty(_cCodProd),PosProd("XXXXXXXXXX",2),PosProd(_cCodProd)),_oDlg:END()},,aBUTTONS) CENTERED
dbSelectArea("SB1")
dbSetOrder(1)
dbSeek( xFilial("SB1")+_cRet )

_auxRet:= .T.

If Empty(_cRet) // <> "XXXXXXXXXX"
	//_auxRet:= ""
	_auxRet:= .F.
EndIf

// Desabilita as teclas F4, F5, F6, F7, F8
//LjTeclas( .T., .F., .F., .T., .F.)

Return (_auxRet)

/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
Static Function _oPesqSB1(_cChave,_cChvGr,_cChvSub,_cChvCla,_cDesc,_cChvFab)

Local _cQuery   := ""
Local _cLegenda                    
Local _oDlgPesq
Local _oOpc              
Local _nCont 
Local _cNome := ""
Local _cRet := ""
Local _i := 0
Local _cCond := ""
Local _nCond := 0
mv_par60 := _cDesc  // Fernando - guarda o conteudo digitado no campo utilizado para pesquisa
If Select("QRY") > 0
	dbSelectArea( "QRY" )  
	dbCloseArea()
EndIf
// Zera o array com os dados dos produtos
_aProduto := {}

// Cria tabela temporaria com os dados dos produtos 

if !lcheck1 // caso seja marcado o checkbox para consultar apenas produtos em estoque

	_cQuery := " SELECT DISTINCT B1_FILIAL, B1_COD CODIGO, rtrim(ltrim("+cDesc+")) DESCRICAO, B1_TIPO TIPO, B1_UM UNIDADE, B1_SEGUM UNID2, B1_MODELO, B1_MSBLQL,"
	_cQuery += " B2_QATU QATU, B1_CODBAR CODBAR, B1_MSBLQL, B1_CONV CONV, B1_TIPCONV TPCONV, "+cPers+" GRTRIB, B1_FABRIC FABRIC, '' SUBGRUPO, '' CLASSE "
	_cQuery += " FROM "+RetSqlName("SB1")+" SB1, " +RetSqlName("SB2")+" SB2 "
	_cQuery += " WHERE "
	_cQuery += " SB1.B1_COD = SB2.B2_COD AND SB1.B1_LOCPAD = SB2.B2_LOCAL" 
	//_cQuery += " AND (SB2.B2_QATU - SB2.B2_RESERVA - SB2.B2_QEMP) >= '1' "  
	_cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
	_cQuery += " AND SB2.D_E_L_E_T_ <> '*' "
	_cQuery += " AND B1_FILIAL = '"+xFilial('SB1')+"' " 
	_cQuery += " AND B2_FILIAL = '"+xFilial('SB2')+"' " 	
	//_cQuery += " AND B1_MSBLQL = '2'"   
	
else

	_cQuery := " SELECT B1_FILIAL, B1_COD CODIGO, rtrim(ltrim("+cDesc+")) DESCRICAO, B1_TIPO TIPO, B1_UM UNIDADE, B1_SEGUM UNID2, B1_MODELO, B1_MSBLQL,"
	_cQuery += " B1_LOCPAD QATU, B1_CODBAR CODBAR, B1_MSBLQL, B1_CONV CONV, B1_TIPCONV TPCONV, "+cPers+" GRTRIB, B1_FABRIC FABRIC, '' SUBGRUPO, '' CLASSE "
	_cQuery += " FROM "+RetSqlName("SB1")+" SB1 "
	_cQuery += " WHERE SB1.D_E_L_E_T_ <> '*' "
	_cQuery += " AND B1_FILIAL = '"+xFilial('SB1')+"' "
	//_cQuery += " AND B1_MSBLQL = '2'" 

endif

IF nPos=1 		//descricao do produto
	_cQuery += " AND (B1_FABRIC   LIKE '%"+Upper(Alltrim(_cDesc))+"%' ) "
ElseIF nPos=2   //codigo do produto 
_cNome := Alltrim(_cDesc)
_cDesc := StrTran( Alltrim(_cNome), " ", "% %" )
_cQuery += " AND B1_DESC   LIKE '%"+Upper(Alltrim(_cDesc))+"%' " 
   //	_cQuery += " AND (B1_DESC   LIKE '%"+Upper(Alltrim(_cDesc))+"%' ) " 
ElseIF nPos=3   //codigo do produto    
	_cQuery += " AND (B1_COD   LIKE '%"+Upper(Alltrim(_cDesc))+"%' ) "
ElseIF nPos=4	//codigo de barras do produto
	_cQuery += " AND (B1_CODBAR   LIKE '%"+Upper(Alltrim(_cDesc))+"%' ) " 
ElseIF nPos=5	//codigo de barras do produto
	_cQuery += " AND (B1_DESCMAR   LIKE '%"+Upper(Alltrim(_cDesc))+"%' ) "	
EndIf

//_cQuery += " ORDER BY rtrim(ltrim("+cDesc+"))"

//memowrit("c:\temp\RFATA001.txt",_cQuery)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQuery),"QRY",.F.,.T.)

_nCont := 0
_PRC2UM:= 0

nAcrescimo := 0
RestArea (aAreaSE4)

While QRY->(!Eof()) .And. _nCont <= 2000

//	IF QRY->B1_X_CURVA == "1" //alto giro
//		_cLegenda	:= "BR_VERDE"
//	ELSEIF QRY->B1_X_CURVA == "2" //medio giro
//		_cLegenda	:= "BR_AMARELO"
//	ELSEIF QRY->B1_X_CURVA == "3" //baixo giro
//		_cLegenda	:= "BR_LARANJA" //"BR_AZUL"
//	ELSEIF QRY->B1_X_CURVA == "4" //Produto novo
//		_cLegenda	:= "BR_PRETO"  //"BR_VERMELHO"
//	ELSEIF QRY->B1_X_CURVA == "5" //sem giro
//		_cLegenda	:= "BR_VERMELHO" //"BR_PRETO"
//	ENDIF
			
	IF QRY->B1_MSBLQL == "1" //prod. bloqueado
		_cLegenda	:= "BR_VERMELHO"
	Else
		_cLegenda	:= "BR_VERDE"
	Endif 
	
	dbSelectArea("QRY")
//	If QRY->TPCONV = 'D'
		//_PRC2UM:= QRY->PRC* QRY->CONV //CONVUM(QRY->CODIGO,1,0,2)
  		_PRC2UM:= 0
//		_PRC2UM:= CONVUM(QRY->CODIGO,QRY->PRC,0,2)
//		_PRC2UM:= CONVUM(QRY->CODIGO,QRY->PRC,0,2)
//	Else
//		_PRC2UM:= QRY->PRC/QRY->CONV 
//	EndIf
//	AAdd(_aProduto, { _cLegenda, QRY->CODIGO, QRY->DESCRICAO,QRY->UNIDADE,QRY->UNID2,QRY->GRUPO,Transform(QRY->PRC,"@E 999,999.99"), QRY->B1_X_REFER } )
	

		IF UPPER(FUNNAME()) == "TMKA271"
		_CTABELA := M->UA_TABELA
	ELSE                            
		IF UPPER(FUNNAME()) == "MATA410"
			_CTABELA := M->C5_TABELA	
		ELSE
			_CTABELA := "001" //M->L1_TABELA			
		ENDIF
	ENDIF
	_npreco := Round(POSICIONE("DA1",1,XFILIAL("DA1")+_CTABELA+QRY->CODIGO,"DA1_PRCVEN") + (POSICIONE("DA1",1,XFILIAL("DA1")+_CTABELA+QRY->CODIGO,"DA1_PRCVEN")*nAcrescimo),2)
	if _npreco == 0 
		//_npreco := Round(POSICIONE("SB1",1,XFILIAL("SB1")+QRY->CODIGO,"B1_PRV1") + (POSICIONE("SB1",1,XFILIAL("SB1")+QRY->CODIGO,"B1_PRV1")*nAcrescimo),2)
		_npreco := Round(POSICIONE("SB0",1,XFILIAL("SB0")+QRY->CODIGO,"B0_PRV1") + (POSICIONE("SB0",1,XFILIAL("SB0")+QRY->CODIGO,"B0_PRV1")*nAcrescimo),2)
	endif			
	IF CNIVEL > 5 
		_CCUSTO := POSICIONE("SB1",1,XFILIAL("SB1")+QRY->CODIGO,"B1_CUSTD")
		AAdd(_aProduto, { _cLegenda, QRY->CODIGO, QRY->DESCRICAO, QRY->TIPO,QRY->UNIDADE,Transform(_npreco,"@E 999,999.99"),Transform(_CCUSTO,"@E 999,999.99"),QRY->QATU,QRY->FABRIC,QRY->GRTRIB, QRY->CODBAR } )
	ELSE
		AAdd(_aProduto, { _cLegenda, QRY->CODIGO, QRY->DESCRICAO, QRY->TIPO,QRY->UNIDADE,Transform(_npreco,"@E 999,999.99"),QRY->QATU,QRY->FABRIC,QRY->GRTRIB, QRY->CODBAR } )
	ENDIF
	QRY->(dbSkip())
	_nCont ++
	
EndDo

_oListBox:nAT := 1 //teste

If !(Len(_aProduto) > 0)
	_aProduto := {} //adicionado leonardo dia 04/01 - melhorar seguranca 
	IF CNIVEL > 5
		AAdd(_aProduto, {"","","","","","","","","","","","","",""} )
	ELSE
		AAdd(_aProduto, {"","","","","","","","","","","","",""} )
	ENDIF
EndIf             

_bAux := _oListBox:bLine
_oListBox:SetArray(_aProduto)
_oListBox:bLine := { || { LoadBitmap(GetResources(), _aProduto[_oListBox:nAT][1]), ;
						_aProduto[_oListBox:nAT][2], ;
						_aProduto[_oListBox:nAT][3], ;
						_aProduto[_oListBox:nAT][4], ;
						_aProduto[_oListBox:nAT][5], ;
						_aProduto[_oListBox:nAT][6], ;
						_aProduto[_oListBox:nAT][7], ;
						_aProduto[_oListBox:nAT][8], ;
						_aProduto[_oListBox:nAT][9], ;
						_aProduto[_oListBox:nAT][10] } }

_oListBox:Refresh()

_oChgProd("T", xFilial("SB2"))

Return(.T.)

/*
Static Function _oVerSB1(_cCodVer)
cCadastro := "Produto"
If !Empty(_cCodVer)
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial()+_cCodVer)
	SB1->(AxVisual("SB1",SB1->(Recno()),1))
	_oListBox:Refresh()
EndIf

Return

Static Function _oVerSF2(_cCodVer2)

_cCodVer2:= substr(_cCodVer2,1,9)+substr(_cCodVer2,11,3)


If !Empty(_cCodVer2)
	dbSelectArea("SF2")
	dbSetOrder(1)
	dbSeek(xFilial("")+_cCodVer2)
	SF2->(MC090Visual("SF2",SF2->(Recno()),1))
	
	_oListBox:Refresh()
EndIf

Return
*/
Static Function _oChgProd(_cOpc, _cFilial)

Local _bAux
Local _cQuery	:= ""
Local _cResult	:= ""
Local cQry		:= ""
Local _TMP		:= ""

If _cOpc == "T"
	
	_nSld1 := 0
	_nSld2 := 0
	_nSld3 := 0
	_nSld4 := 0

	_cResult := GetNextAlias()
	_cQuery  += " SELECT B2_FILIAL FILIAL, B2_LOCAL LOCPAD, B2_QATU ATUAL,(B2_QATU - B2_RESERVA - B2_QEMP) SALDO, B2_RESERVA RESERVA, B2_SALPEDI SALPED "
	_cQuery  += " FROM "+RetSqlName("SB2")+" SB2 "
	_cQuery  += " WHERE SB2.D_E_L_E_T_ = ' ' "
	_cQuery  += " AND SB2.B2_COD = '"+_aProduto[_oListBox:nAT][2]+"' "
	_cQuery  += " ORDER BY FILIAL "
	
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQuery),_cResult,.F.,.T.)
//	MemoWrite("d:\temp\consulta1.sql",_cQuery)
	TcSetField(_cResult, "SALDO" , "N", 15, 2)
	
	_aSldFil := {}
	dbSelectArea(_cResult)
	dbGoTop()
	While !Eof()                                         
		AAdd(_aSldFil,{(_cResult)->FILIAL,(_cResult)->LOCPAD,Transform((_cResult)->ATUAL,"@E 999,999,999.99"), Transform((_cResult)->SALDO,"@E 999,999,999.99"),Transform((_cResult)->RESERVA,"@E 999,999,999.99"),Transform((_cResult)->SALPED,"@E 999,999,999.99") } )
		dbSkip()	
	EndDo
	dbCloseArea()	
	// Tratamento de erro caso nao encontre nenhum registro na tabela SB2
	If Len(_aSldFil) == 0
		AAdd(_aSldFil, {"","",Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99"),Transform(0,"@E 999,999,999.99")} )
	EndIf	

	_bAux := _oSldFil:bLine
	_oSldFil:SetArray(_aSldFil)
	_oSldFil:bLine := _bAux	

	_oSldFil:Refresh()
ENDIF
        
//IMAGEM
IF !EMPTY(_aProduto[_oListBox:nAT][2])
	_CIMAGEM := alltrim(_aProduto[_oListBox:nAT][2])+".jpg" 
	IF oTBitmap2:Load( , "\imagens\"+_CIMAGEM)
		oTBitmap2:cBmpFile := _CIMAGEM
		oTBitmap2:lStretch := .T.
		oTBitmap2:REFRESH()
	ELSE                  
		oTBitmap2:cBmpFile := "\imagens\Produto_Em_Branco.jpg" 
		oTBitmap2:lStretch := .T.
		oTBitmap2:REFRESH()	    
	ENDIF
ENDIF

// Posiciona no cadastro de produtos
SB1->( dbSetOrder(1) )
SB1->( dbSeek( xFilial("SB1")+_aProduto[_oListBox:nAT][2] ) )

Return       

Static Function PosProd(_cProd,_xnopc)
If _xnopc = 2
	dbSelectArea("SB1")
	dbSetOrder(1)
	SB1->(dbGoTop())
Else
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek( xFilial("SB1")+_cProd )	
	_cRet := _cProd
//	_cRet := SPACE(TAMSX3("B1_COD")[1])
EndIf

Return

USER FUNCTION PESQD2(_cCodProd)


// Variaveis Locais da Funcao
Local cGet1	 := Space(25)
Local oGet1
Local _aTit := {}

// Variaveis Private da Funcao
Private oDlg				// Dialog Principal
// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.                        
Private INCLUI := .F.                        
Private ALTERA := .F.                        
Private DELETA := .F.                        
// Privates das ListBoxes
Private _aItens := {}
Private aListBox1 := {}
Private _oListBox1

DEFINE MSDIALOG oDlg TITLE "Desc. Complementar" FROM C(178),C(181) TO C(500),C(730) PIXEL

	// Cria Componentes Padroes do Sistema
	@ 002,001 GET cGet1 SIZE 185,9 PIXEL
	DEFINE SBUTTON FROM C(002),C(148) TYPE 1 ACTION (_oPesqSD2(cGet1)) ENABLE OF oDlg

// Cria listbox com os dados dos produtos conforme a tabela temporaria criada
AAdd(_aItens, {"","","","","","","",""} )
//	AAdd(_aItens, { "", QRY->DOC, QRY->CODIGO, POSICIONE("SB1",1,XFILIAL("SB1")+QRY->CODIGO,"B1_DESC"),QRY->DESCRICAO, QRY->D2_EMISSAO, QRY->D2_QUANT, QRY->D2_PRCVEN } )
//AAdd(_aTit, {"","Nota","Produto","Descrição","Descrição Complementar"})
//	EMISSAO | QTDE  | PRC UNIT. |  NUM NOTA  |  COD PRODUTO  | DESCRICAO 	
AAdd(_aTit, {"","Emissão","Quant","Prc.Unit.","Nota","Produto","Descrição","Descrição Complementar"})
AAdd(_aTit, {12,15,15,15,30,30,100,100})

_oListBox1 := TWBrowse():New(015,001,350,190,,_aTit[1],_aTit[2],oDlg,,,,,,,,,,,,.F.,,.T.,,.F.)
_oListBox1:blDblClick := {|| PosProd(_aItens[_oListBox1:nAT][06] ), oDlg:End() }
_oListBox1:SetArray(_aItens)
_oListBox1:bLine := { || { LoadBitmap(GetResources()  ,;
                          _aItens[_oListBox1:nAT][01]),;
                          _aItens[_oListBox1:nAT][02] ,;
                          _aItens[_oListBox1:nAT][03] ,;
                          _aItens[_oListBox1:nAT][04],;
                          _aItens[_oListBox1:nAT][05] ,;
                          _aItens[_oListBox1:nAT][06] ,;
                          _aItens[_oListBox1:nAT][07] ,;
                          _aItens[_oListBox1:nAT][08] } }

If _cCodProd <> Nil
	If !Empty(_cCodProd)
		_oPesqSB1(_cCodProd)
	EndIf
EndIf

ACTIVATE MSDIALOG oDlg CENTERED 

dbSelectArea("SB1")
dbSetOrder(1)
dbSeek( xFilial("SB1")+_cRet )

_oPesqSB1(_cRet)

RETURN(.T.)


USER FUNCTION PESSIT(_cCodProd)

// Variaveis Locais da Funcao
Local cMemo1	 := POSICIONE("SB1",1,XFILIAL("SB1")+_aProduto[_oListBox:nAT][2],"B1_XDESCST")
Local cMemo2	 := POSICIONE("SB5",1,XFILIAL("SB5")+_aProduto[_oListBox:nAT][2],"B5_X_ESPEC")
Local oMemo1
Local oMemo2

// Variaveis Private da Funcao
Private oDlg

DEFINE MSDIALOG oDlg TITLE "Descrição Site" FROM C(199),C(183) TO C(508),C(721) PIXEL

	// Cria as Groups do Sistema
	@ C(000),C(003) TO C(070),C(264) LABEL "Desc. Site" PIXEL OF oDlg
	@ C(075),C(003) TO C(145),C(264) LABEL "Desc.Sistema" PIXEL OF oDlg

	// Cria Componentes Padroes do Sistema
	@ C(008),C(004) GET oMemo1 Var cMemo1 MEMO Size C(255),C(060) PIXEL OF oDlg When .F.
	@ C(083),C(005) GET oMemo2 Var cMemo2 MEMO Size C(255),C(060) PIXEL OF oDlg When .F.
	DEFINE SBUTTON FROM C(188),C(235) TYPE 1 ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

RETURN(.T.)

USER FUNCTION ALTINF
// Variaveis Locais da Funcao
Local cMemo1	 := POSICIONE("SB5",1,XFILIAL("SB5")+_aProduto[_oListBox:nAT][2],"B5_X_ESPEC")
Local oMemo1

// Variaveis Private da Funcao
Private oDlg

DEFINE MSDIALOG oDlg TITLE "Informações Técnicas" FROM C(199),C(183) TO C(380),C(721) PIXEL

	// Cria as Groups do Sistema
	@ C(000),C(003) TO C(070),C(264) LABEL "Desc. Sistema" PIXEL OF oDlg


	// Cria Componentes Padroes do Sistema
	@ C(008),C(004) GET oMemo1 Var cMemo1 MEMO Size C(255),C(060) PIXEL OF oDlg 

  
 	DEFINE SBUTTON FROM C(075),C(215) TYPE 1 ENABLE OF oDlg ACTION(U_GRVINF(cMemo1),oDlg:End())
	DEFINE SBUTTON FROM C(075),C(240) TYPE 2 ENABLE OF oDlg ACTION(oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

RETURN

USER FUNCTION GRVINF(cMemo1)

dbSelectArea("SB5")
dbSetOrder(1)
If dbSeek(xFilial("SB5")+_aProduto[_oListBox:nAT][2])
	RecLock("SB5",.F.)
		SB5->B5_X_ESPEC := cMemo1
	SB5->(MsUnLock())
EndIf


RETURN
/*
Static Function fListBox1()

_aTit:={}

// Carrege aqui sua array da Listbox
Aadd(aListBox1,{""})

AAdd(_aTit, {"","Codigo","Descrição","Tipo","U.M.","Grupo","Referência","Fornecedor","Cod.Barras"})
AAdd(_aTit, {10,50,100,10,10,30,30,20,50})

oListBox1 := TWBrowse():New(027,001,500,120,,_aTit[1],_aTit[2],_oDlg,,,,,,,,,,,,.F.,,.T.,,.F.)	
oListBox1:SetArray(aListBox1)
oListBox1:bLine := { || { LoadBitmap(GetResources()    ,;
                         aListBox1[oListBox1:nAT][01]) } }
Return Nil                                                                                                                      
*/

Static Function C(nTam)                                                         
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
		nTam *= 0.8                                                                
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600                
		nTam *= 1                                                                  
	Else	// Resolucao 1024x768 e acima                                           
		nTam *= 1.28                                                               
	EndIf                                                                         
                                                                                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                               
	//³Tratamento para tema "Flat"³                                               
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                               
	If "MP8" $ oApp:cVersion                                                      
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()                      
			nTam *= 0.90                                                            
		EndIf                                                                      
	EndIf                                                                         
Return Int(nTam)                                                                


Static Function _oPesqSD2(_cChave)

Local _cQuery   := ""
Local _cLegenda
Local _oDlgPesq
Local _oOpc              
Local _nCont 

If Select("QRY") > 0
	dbSelectArea( "QRY" )  
	dbCloseArea()
EndIf
// Zera o array com os dados dos itens da nota fiscal
_aItens := {}

// Cria tabela temporaria com os dados dos itens da nota 
_cQuery := " SELECT D2_FILIAL, D2_COD CODIGO, D2_ITEM ITEM, D2_SERIE SERIE, "
_cQuery += " D2_DOC DOC, D2_EMISSAO, D2_QUANT, D2_PRCVEN "
_cQuery += " FROM "+RetSqlName("SD2")+" SD2 "
_cQuery += " WHERE SD2.D_E_L_E_T_ <> '*' "
If FunName()=="LOJA701".OR. FunName()=="RLOJA010"
	_cQuery += " AND D2_CLIENTE = '"+M->LQ_CLIENTE+"'"
	_cQuery += " AND D2_LOJA ='" +M->LQ_LOJA+ "'"
EndIf
//_cQuery += " AND D2_XDESC LIKE '%"+Upper(Alltrim(_cChave))+"%' "
_cQuery += " ORDER BY D2_DOC, D2_ITEM"
  
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQuery),"QRY",.F.,.T.)                                 

_nCont := 0

While QRY->(!Eof()) .And. _nCont <= 100

	dbSelectArea("QRY")
//	EMISSAO | QTDE  | PRC UNIT. |  NUM NOTA  |  COD PRODUTO  | DESCRICAO 	
//	AAdd(_aItens, { "", QRY->DOC, QRY->CODIGO, POSICIONE("SB1",1,XFILIAL("SB1")+QRY->CODIGO,"B1_DESC"),QRY->DESCRICAO } )
	AAdd(_aItens, { "", STOD(QRY->D2_EMISSAO), QRY->D2_QUANT, QRY->D2_PRCVEN, QRY->DOC, QRY->CODIGO, POSICIONE("SB1",1,XFILIAL("SB1")+QRY->CODIGO,"B1_XDESC"),QRY->DESCRICAO } )
	QRY->(dbSkip())
	_nCont ++
	
EndDo

If Len(_aItens) == 0
	AAdd(_aItens, {"","","","","","","",""} )
EndIf             

bAux := _oListBox1:bLine
_oListBox1:SetArray(_aItens)
_oListBox1:bLine := { || { LoadBitmap(GetResources(), _aItens[_oListBox1:nAT][1]), ;
						_aItens[_oListBox1:nAT][2], ;
						_aItens[_oListBox1:nAT][3], ;
						_aItens[_oListBox1:nAT][4], ;
						_aItens[_oListBox1:nAT][5], ;
						_aItens[_oListBox1:nAT][6], ;						
						_aItens[_oListBox1:nAT][7], ;						
						_aItens[_oListBox1:nAT][8] } }

_oListBox1:Refresh()

Return



USER FUNCTION VERSC7(_cProd,_cSal,_cFill,_cEmp)

Local aArea	   := GETAREA()
Local nCnt     := 0
Local nOpcA    := 0
Local cVarTemp := ""
Local oDlg     := Nil
Local oGet     := Nil
// Vetor com os campos que poderao ser alterados                                                                                
Local aAlter := {""}
Local nSuperior    	:= C(004)
Local nEsquerda    	:= C(000)
Local nInferior    	:= C(100)
Local nDireita     	:= C(348)
Local cLinhaOk     	:= "AllwaysTrue"
Local cTudoOk      	:= "AllwaysTrue"
Local cLinOk       	:= "AllwaysTrue"
Local cIniCpos     	:= "+LR_ITEM"
Local nFreeze      	:= 000
Local nMax         	:= 999
Local cCampoOk     	:= "AllwaysTrue"
Local cSuperApagar 	:= ""
Local cApagaOk     	:= "AllwaysTrue"
Local oWnd          	:= oDlg
Local cFieldOk     	:= "AllwaysTrue"
Local cSuperDel     	:= ""
Local cDelOk        	:= "AllwaysTrue"
Local nOpc         := GD_INSERT+GD_DELETE+GD_UPDATE
Local aButtons  := {}
Local _nTotBase := 0
Local _nTotOrc	:= 0
Local _nSal		:= 0 //saldo dos pedidos
Local _cXemp	:= _cEmp

Private _aHead := {}
Private _aCOLS   := {}
Private nUsado  := 0

//Private cFilOrc := SLQ->LQ_FILIAL
//Private cOrcam  := SLQ->LQ_NUM


_aHead := {}
// Array para montar a Tabela Temporaria aHeader
AADD(_aHead,{"Filial"	,"C7_FILIAL","",2,0,,,"C", "SC7", }) 
AADD(_aHead,{"Num.Ped."		,"C7_NUM","@!",06,0,,,"C", "SC7", }) 
AADD(_aHead,{"Fornec."		,"C7_FORNECE","@!",08,0,,,"C", "SC7", }) 
AADD(_aHead,{"Desc."		,"C7_DESCRI","@!",25,0,,,"C", "SC7", }) 
AADD(_aHead,{"Dt.Entrega" ,"C7_DATPRF","@D",08,0,,,"D", "SC7", }) 
AADD(_aHead,{"Quant." ,"C7_QUANT","@E 999,999,999.99",14,2,,,"N", "SC7", }) 


	//Query contendo as regras a serem mostradas
	cQry := " SELECT *"
	If _cXemp <> NIL 
		cQry += " FROM SC7"+ALLTRIM(_cXemp)+"0 SC7 "
	Else
		cQry += " FROM "+RetSqlName("SC7")+" SC7 "	
	EndIf
	cQry += " WHERE SC7.D_E_L_E_T_='' "
	cQry += " AND C7_QUJE < C7_QUANT "
	cQry += " AND C7_PRODUTO = '"+_cProd+"'"
	If _cFill <> nil
		cQry += " AND C7_FILIAL = '"+_cFill+"'"
	ENdIf
	cQry += " ORDER BY C7_NUM"	
		
	If Select("TMP") > 0
		TMP->(dbCloseArea())
	EndIf
	
	cQry := ChangeQuery(cQry)
	
	dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQry), "TMP", .F., .T.)


// Array para montar o aCols
WHILE TMP->(!EOF())
	If TMP->C7_QUANT-TMP->C7_QUJE > 0 .AND. TMP->C7_RESIDUO <> 'S'
	_cNomFor	:= Posicione("SA2",1,XFILIAL("SA2")+TMP->(C7_FORNECE+C7_LOJA),"A2_NOME")
	AADD(_aCols,{TMP->C7_FILIAL,TMP->C7_NUM,TMP->C7_FORNECE,SUBSTR(_cNomFor,1,25),STOD(TMP->C7_DATPRF),TMP->C7_QUANT-TMP->C7_QUJE,.F.})
	_nSal+= TMP->C7_QUANT-TMP->C7_QUJE
	EndIf
TMP->(DBSKIP())
ENDDO

If _cSal = nil

If LEN(_aCols) = 0
	Aviso("Atenção","Não existe pedido em aberto para este produto.",{"OK"})
	Return
EndIf

DEFINE MSDIALOG oDlg TITLE "Pedido de Compras em Aberto" FROM C(178),C(181) TO C(418),C(887) PIXEL


	DEFINE SBUTTON FROM C(105),C(320) TYPE 1 ENABLE OF oDlg ACTION (oDlg:End()) //TOOLTIP "OK"
	
	// Chamadas das GetDados do Sistema
	oGet:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;
                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oWnd,_aHead,_aCols)
	
ACTIVATE MSDIALOG oDlg CENTERED 

Else
	RestArea(aArea)
	Return(_nSal)
EndIf

RestArea(aArea)
Return


USER FUNCTION _PCUS(_EMP,_PROD,_xFil,_cTinta)

Local	_aArea 	:= GetArea() 
Local	_aRet	:= {}
Local 	_dDtEnt	:= CTOD("  /  /    ")
Local  i        := 0
If FUNNAME() $ "RMATA005"
	_aFiliais := {}
	aAdd(_aFiliais,{SM0->M0_CODFIL,SM0->M0_FILIAL})

	_cFiliais := ''
	for i := 1 to len(_aFiliais)
		_cFiliais += "'"+_aFiliais[i,1]+"'"
		if i < len(_aFiliais)
			_cFiliais += ','
		endif
	next i	
EndIf

dbSelectArea("SB1")
SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1")+_PROD))

_VlrCus	:= 0
_VlrIpi	:= 0 
_VlrIcm	:= 0 
_VlrDes	:= 0 
	If 0 == 1//SB1->B1_X_TINTA <> 'S' //se nao for tinta
	//notas de entrada sem tranferencia
	_cQry  := " SELECT D1_QUANT, D1_VALIPI, D1_VALICM, F1_FRETE, F1_DESPESA, D1_COD, D1_EMISSAO, D1_VUNIT, F1_EMISSAO, F1_DTDIGIT, D1_CUSTO, D1_NUMSEQ, D1_DTDIGIT, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_ITEM "
	If _EMP = '1'
		_cQry  += " FROM SD1010 SD1, SF1010 SF1, SF4010 SF4 "
	ElseIf _EMP = '2'
		_cQry  += " FROM SD1020 SD1, SF1020 SF1, SF4010 SF4 "
	ElseIf _EMP = '3'
		_cQry  += " FROM SD1030 SD1, SF1030 SF1, SF4010 SF4 "
	Else
		_cQry += " FROM "+RetSqlName("SD1")+" SD1, "+RetSqlName("SF1")+" SF1, "+RetSqlName("SF4")+" SF4 "
	EndIf
	_cQry  += " WHERE SD1.D_E_L_E_T_<>'*' "
	_cQry  += " AND SF1.D_E_L_E_T_<>'*' "
	_cQry  += " AND SF4.D_E_L_E_T_<>'*' "
	_cQry  += " AND F1_FILIAL = D1_FILIAL "
	_cQry  += " AND F1_DOC = D1_DOC "
	_cQry  += " AND F1_SERIE = D1_SERIE "
	_cQry  += " AND F1_FORNECE = D1_FORNECE "
	_cQry  += " AND F1_LOJA = D1_LOJA "
	_cQry  += " AND D1_COD = '"+_PROD+"' "
	_cQry  += "	AND D1_TIPO 	= 'N' "
	_cQry  += "	AND D1_TES = F4_CODIGO "	
	_cQry  += "	AND D1_QUANT > 0 "	
	_cQry  += "	AND F4_DUPLIC 	= 'S' "
	_cQry  += "	AND F4_ESTOQUE 	= 'S' "	
//	_cQry  += " AND D1_FILIAL = '"+_xFil+"' "
	_cQry  += " ORDER BY D1_DTDIGIT DESC , D1_NUMSEQ DESC "

	If Select("TMPCUS") > 0
		TMPCUS->(dbCloseArea())
	EndIf
	
	_cQry := ChangeQuery(_cQry)
	
	dbUseArea(.T.,"TOPCONN", TCGenQry(,,_cQry), "TMPCUS", .F., .T.)
	
	IF !TMPCUS->(EOF()) //!Empty("TMPCUS")
		_VlrIpi	:= TMPCUS->D1_VALIPI/TMPCUS->D1_QUANT
		_VlrIcm	:= TMPCUS->D1_VALICM/TMPCUS->D1_QUANT
		_VlrDes	:= (TMPCUS->(F1_FRETE+F1_DESPESA))/TMPCUS->D1_QUANT
	
		_VlrCus	:= TMPCUS->D1_CUSTO/TMPCUS->D1_QUANT //TMPCUS->D1_VUNIT+_VlrIpi+_VlrIcm+_VlrDes
		_dDtEnt	:= STOD(TMPCUS->F1_DTDIGIT)
		//Verifico frete
		DbSelectArea("SF8")
		DbSetOrder(2)
//		If DbSeek(xFilial("SF8")+TMPCUS->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA))
		If DbSeek("01"+TMPCUS->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA))
			DbSelectArea("SD1")
			DbSetOrder(1)
			//DbSeek(xFilial("SD1")+SF8->(	F8_NFDIFRE+F8_SEDIFRE+F8_TRANSP+F8_LOJTRAN)+TMPCUS->D1_COD) //+TMPCUS->D1_ITEM)
			If DbSeek("01"+SF8->(	F8_NFDIFRE+F8_SEDIFRE+F8_TRANSP+F8_LOJTRAN)+TMPCUS->D1_COD) //+TMPCUS->D1_ITEM)
	
				cGet6 := Round(SD1->D1_CUSTO,4) //VALOR TOTAL DO FRETE...
				
				//AGORA PRECISO DA QUANTIDADE REAL (PODE TER MAIS DE UMA NOTA EM UM UNICO CONHECIMENTO DE FRETE COM O MESMO PRODUTO) 

				_cSQLFRT := " SELECT D1_COD, SUM(D1_QUANT) AS QUANT"
				_cSQLFRT += " FROM " + RetSqlName("SD1") + " SD1 INNER JOIN " + RetSqlName("SF8") + " SF8 "
				_cSQLFRT += "     ON  D1_FILIAL = F8_FILIAL "
				_cSQLFRT += "         AND D1_DOC = F8_NFORIG "
				_cSQLFRT += "         AND D1_SERIE = F8_SERORIG "
				_cSQLFRT += "         AND D1_FORNECE = F8_FORNECE "
				_cSQLFRT += "         AND D1_LOJA = F8_LOJA "
				_cSQLFRT += " 	      AND F8_NFDIFRE = '" + SF8->F8_NFDIFRE + "' "
				_cSQLFRT += " 	      AND F8_SEDIFRE = '" + SF8->F8_SEDIFRE + "' "
				_cSQLFRT += "         AND D1_COD = '" + TMPCUS->D1_COD + "' "
				_cSQLFRT += "         AND SD1.D_E_L_E_T_ != '*' "
				_cSQLFRT += "         AND SF8.D_E_L_E_T_ != '*' "
				_cSQLFRT += "         AND SD1.D1_FILIAL IN ("+_cFiliais+")" //Atualizacao feita por Fernando Vallim para agilizar as consultas aninhadas (Melhorar o CUSTO de excecucao do SQL - 24/11/10)
				_cSQLFRT += "         AND SF8.F8_FILIAL IN ("+_cFiliais+")"
				_cSQLFRT += " GROUP BY D1_COD "
	
				If Select("SQLFRT") > 0
					SQLFRT->(DbCloseArea())
				EndIf
				
				TcQuery _cSqlFrt New Alias "SQLFRT"
	
				DbSelectArea("SQLFRT")
//				SQLFRT->(DbGoTop())
				If SQLFRT->(!Eof())
					cGet6 := cGet6 / SQLFRT->QUANT
				Else
					cGet6 := 0
				EndIf
				SQLFRT->(DbCloseArea())
				
				_VlrCus += cGet6
			EndIf
		EndIf		
	Else
		dbSelectArea("SB9")
		dbSetOrder(1)
		If dbSeek("01"+PADR(ALLTRIM(_PROD),TAMSX3("B9_COD")[1],'')) //01 pois o custo sera o da matriz se nao tiver entrada
			_VlrCus := SB9->B9_CM1

		ElseIf dbSeek("02"+PADR(ALLTRIM(_PROD),TAMSX3("B9_COD")[1],'')) //ppg
			_VlrCus := SB9->B9_CM1
		EndIf
	ENDIF 
	Else
	
		_VlrCus := 0//U_RMATA012(SB1->B1_COD,1)
		//_VlrCus := _nCusto/TMP->B2_QATU
	EndIf
	
	AADD(_aRet,{_VlrCus,DTOC(_dDtEnt)})
RestArea(_aArea)
RETURN _aRet //_VlrCus


User Function RETEND(EMP,FIL)
Local cRet	:= ""
Local _cArea	:= GETAREA()
//_XEnd	:= Transform(POSICIONE("SBZ",1,(_cResult)->FILIAL+_aProduto[_oListBox:nAT][2],"BZ_XLOCAL+BZ_XRUA+BZ_XLOTE"),"@R 9999-9999-9999") //endereco	
	xcQry  := " SELECT *"
	If EMP = '01'
		xcQry  += " FROM SBZ010 SBZ "
	ElseIf EMP = '02'
		xcQry  += " FROM SBZ020 SBZ "
	ElseIf EMP = '03'
		xcQry  += " FROM SBZ030 SBZ"
	Else
		xcQry += " FROM "+RetSqlName("SBZ")+" SBZ "
	EndIf
	xcQry  += " WHERE SBZ.D_E_L_E_T_<>'*' "
	xcQry  += " AND BZ_FILIAL = '"+FIL+"' "
	xcQry  += " AND BZ_COD = '"+_aProduto[_oListBox:nAT][2]+"' "
	
	If Select("TMPEND") > 0
		TMPEND->(dbCloseArea())
	EndIf
	
	xcQry := ChangeQuery(xcQry)
	
	dbUseArea(.T.,"TOPCONN", TCGenQry(,,xcQry), "TMPEND", .F., .T.)
	
	If !TMPEND->(EOF())
		cRet:= TMPEND->(BZ_XLOCAL+BZ_XRUA+BZ_XLOTE)
	EndIf

cRet:= Transform(cRet,"@R 9999-9999-9999")
RESTAREA(_cArea)
Return cRet
/*
Static Function Lote(_cProd,_cFil,_cEmp)

Local aArea		:= GetArea()
Local cFilOld	:= cFilant

cFilAnt := _cFil

u__F4Lote(,,,"ZZZ",PADR(ALLTRIM(_cProd),TAMSX3("B1_cod")[1],""),"01",.F.,,_cEmp,_cFil)

cFilAnt := cFilOld

RestArea(aArea)
Return NIL 

Static Function VERCOMP(_Prod)

// Variaveis Locais da Funcao
Local cGet1	 := ""
Local oGet1

// Variaveis Private da Funcao
Private oDlg

DbSelectArea("SB1")
DbSetOrder(1)

DbSelectArea("SY1")
DbSetOrder(1)

DbSelectArea("SA2")
DbSetOrder(1)


SB1->(DbSeek(xFilial("SB1")+_Prod))

_cForn := SB1->B1_PROC
_cLoja := SB1->B1_LOJPROC

SA2->(DbSeek(xFilial("SA2")+_cForn+_cLoja))



If cEmpAnt == '01'
	SY1->(DbSeek(xFilial("SY1")+SA2->A2_XCOMPRA))
	cGet1 := Alltrim(SA2->A2_XCOMPRA)+" - "+Alltrim(SY1->Y1_NOME)
Else 
	If cEmpAnt == '02'
		SY1->(DbSeek(xFilial("SY1")+SA2->A2_XCOMPR2))
		cGet1 := Alltrim(SA2->A2_XCOMPR2)+" - "+Alltrim(SY1->Y1_NOME)
	Else
		SY1->(DbSeek(xFilial("SY1")+SA2->A2_XCOMPR3))
		cGet1 := Alltrim(SA2->A2_XCOMPR3)+" - "+Alltrim(SY1->Y1_NOME)		
	EndIf
EndIf	

DEFINE MSDIALOG oDlg TITLE "Comprador do Produto" FROM C(199),C(183) TO C(380),C(721) PIXEL

// Cria as Groups do Sistema
@ C(000),C(003) TO C(070),C(264) LABEL "Comprador" PIXEL OF oDlg

// Cria Componentes Padroes do Sistema
@ C(008),C(004) GET oGet1 Var cGet1  Size C(255),C(060)COLOR CLR_BLACK PIXEL OF oDlg 
  
// DEFINE SBUTTON FROM C(075),C(215) TYPE 1 ENABLE OF oDlg ACTION(U_GRVINF(cMemo1),oDlg:End())
DEFINE SBUTTON FROM C(075),C(240) TYPE 2 ENABLE OF oDlg ACTION(oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

RETURN
*/
//////////////////////////////////////////////////////////////////////////////////
User Function ESPECIF_PROD(_CCODPRO)

LOCAL _CDESCRI := POSICIONE("SB1",1,XFILIAL("SB1")+_CCODPRO,"B1_DESCRI")
PRIVATE OMEM01  
PRIVATE OMEM02
DEFINE DIALOG oDlg TITLE "Especificação do Produto" FROM 000, 000  TO 400, 400 PIXEL

@ C(001),C(001) GET oMemo1 Var _CDESCRI MEMO Size C(157.5),C(155) PIXEL OF oDlg
oMemo1:LREADONLY := .T. 

ACTIVATE DIALOG oDlg CENTERED 
Return

//////////////////////////////////////////////////////////////////////////////////
Static Function TabPrecos(_cCODPRO)

LOCAL _CDESCRI  := POSICIONE("SB1",1,XFILIAL("SB1")+_cCODPRO,"B1_DESC")
Private nPrv1	:= Transform(POSICIONE("SB0",1,XFILIAL("SB0")+_cCODPRO,"B0_PRV1"),PesqPict("SB0","B0_PRV1"))
Private nPrv2	:= Transform(POSICIONE("SB0",1,XFILIAL("SB0")+_cCODPRO,"B0_PRV2"),PesqPict("SB0","B0_PRV2"))
Private nPrv3	:= Transform(POSICIONE("SB0",1,XFILIAL("SB0")+_cCODPRO,"B0_PRV3"),PesqPict("SB0","B0_PRV3"))
Private nPrv4	:= Transform(POSICIONE("SB0",1,XFILIAL("SB0")+_cCODPRO,"B0_PRV4"),PesqPict("SB0","B0_PRV4"))
Private nPrv5	:= Transform(POSICIONE("SB0",1,XFILIAL("SB0")+_cCODPRO,"B0_PRV5"),PesqPict("SB0","B0_PRV5"))
Private nPrv6	:= Transform(POSICIONE("SB0",1,XFILIAL("SB0")+_cCODPRO,"B0_PRV6"),PesqPict("SB0","B0_PRV6"))
Private nPrv7	:= Transform(POSICIONE("SB0",1,XFILIAL("SB0")+_cCODPRO,"B0_PRV7"),PesqPict("SB0","B0_PRV7"))
Private nPrv8	:= Transform(POSICIONE("SB0",1,XFILIAL("SB0")+_cCODPRO,"B0_PRV8"),PesqPict("SB0","B0_PRV8"))
Private nPrv9	:= Transform(POSICIONE("SB0",1,XFILIAL("SB0")+_cCODPRO,"B0_PRV9"),PesqPict("SB0","B0_PRV9"))

//Inicio da tela com as 9 tabela de precos da SB0 do produto selecionado
DEFINE MSDIALOG _oDlgSb0 TITLE "Tabela de Preços" FROM 064,250 TO 230,630 PIXEL
oSay  := TSay():New(008,010, {||Alltrim(_cCODPRO)+"-"+Alltrim(_CDESCRI)},_oDlgSb0,,oFont16n,,,,.T.,CLR_RED,)
//oGet1 := TGet():New(015,010,{|u|iif(PCount()==0,_cDesc,_cDesc:=u)},oGroup,150,10,"@!",,0,,,.F.,,.T.,,.F.,{||},.F.,.F.,{||},.F.,.F.,,_cDesc,,,, )   
oSay  := TSay():New(020,020, {||"Tabela 1"},_oDlgSb0,,oFont13,,,,.T.,CLR_BLUE,)
@ 027,020 Get    nPrv1   Size 030,008 PIXEL OF _oDlgSb0 //Picture "99.99"		 	
oSay  := TSay():New(020,060, {||"Tabela 2"},_oDlgSb0,,oFont13,,,,.T.,CLR_BLUE,)
@ 027,060 Get    nPrv2   Size 030,008 PIXEL OF _oDlgSb0 //Picture "@E 99.99"		 	
oSay  := TSay():New(020,100, {||"Tabela 3"},_oDlgSb0,,oFont13,,,,.T.,CLR_BLUE,)
@ 027,100 Get    nPrv3   Size 030,008 PIXEL OF _oDlgSb0 //Picture "@R 99.99"		 	
oSay  := TSay():New(020,140, {||"Tabela 4"},_oDlgSb0,,oFont13,,,,.T.,CLR_BLUE,)
@ 027,140 Get    nPrv4   Size 030,008 PIXEL OF _oDlgSb0 //Picture "@E 999,999.99"		 	
oSay  := TSay():New(041,010, {||"Tabela 5"},_oDlgSb0,,oFont13,,,,.T.,CLR_BLUE,)
@ 048,010 Get    nPrv5   Size 030,008 PIXEL OF _oDlgSb0 //Picture "99.99"		 	
oSay  := TSay():New(041,045, {||"Tabela 6"},_oDlgSb0,,oFont13,,,,.T.,CLR_BLUE,)
@ 048,045 Get    nPrv6   Size 030,008 PIXEL OF _oDlgSb0 //Picture "@E 99.99"		 	
oSay  := TSay():New(041,080, {||"Tabela 7"},_oDlgSb0,,oFont13,,,,.T.,CLR_BLUE,)
@ 048,080 Get    nPrv7   Size 030,008 PIXEL OF _oDlgSb0 //Picture "@R 99.99"		 	
oSay  := TSay():New(041,115, {||"Tabela 8"},_oDlgSb0,,oFont13,,,,.T.,CLR_BLUE,)
@ 048,115 Get    nPrv8   Size 030,008 PIXEL OF _oDlgSb0 //Picture "@E 999,999.99"		 	
oSay  := TSay():New(041,150, {||"Tabela 9"},_oDlgSb0,,oFont13,,,,.T.,CLR_BLUE,)
@ 048,150 Get    nPrv9   Size 030,008 PIXEL OF _oDlgSb0 //Picture "@E 999,999.99"		 	

oSButton2 := SButton():New( 067,160,1,{|lEnd| AtuSB0(_cCODPRO)},_oDlgSb0,.T.,,)   
oSButton1 := SButton():New( 067,130,2,{|lEnd| (@lEnd)},_oDlgSb0,.T.,,)   

ACTIVATE DIALOG _oDlgSb0 CENTERED 

//////////////////////////////////////////////////////////////////////////////////
Static Function AtuSB0(_cCODPRO)

    if SB0->(dbSeek(xFilial('SB0')+_cCODPRO))
       Reclock('SB0', .f.)
	   SB0->B0_PRV1 	 := FormaNum(nPrv1)
	   SB0->B0_PRV2 	 := FormaNum(nPrv2)
	   SB0->B0_PRV3 	 := FormaNum(nPrv3)
	   SB0->B0_PRV4 	 := FormaNum(nPrv4)
	   SB0->B0_PRV5 	 := FormaNum(nPrv5)
	   SB0->B0_PRV6 	 := FormaNum(nPrv6)
	   SB0->B0_PRV7 	 := FormaNum(nPrv7)
	   SB0->B0_PRV8 	 := FormaNum(nPrv8)
	   SB0->B0_PRV9 	 := FormaNum(nPrv9)
	   SB0->(MsUnLock())    
       MsgAlert('Tabelas de Preços atualizada com Sucesso...')
    else
       MsgAlert('Tabelas de Preços não atualizada!')
    endif
//    SB0->B0_DTALTER  := DDATABASE
//    SB0->B0_USUARIO  := CUSERNAME
//    SB0->B0_PTEQ     := FormaNum(_aDados[_nTx][6]) 

_oDlgSb0:End()
Return .T.
//Fim AtuSB0//////////////////////////////////////////////////////////////////////

/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FormaNum ºAutor  ³Alisson Alessandro	 º Data ³  03/09/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
*/
Static Function FormaNum(_cValor)
Local _cCarac  := "" 
Local _nT      := 0
  _cRet :=''
  For _nT := 1 to Len(_cValor)
     _cCarac := SubStr(_cValor,_nT,1)
     if _cCarac <> '.'
        _cRet += iif(_cCarac = ',','.',_cCarac)        
     endif
  Next     
  
  if Empty(_cRet) 
     _cRet := '0'
  endif         
  
  _nRet := Val(_cRet)        
  
Return _nRet

Return
