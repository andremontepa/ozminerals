#Include "PROTHEUS.CH"
#Include "DBTREE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³COMM003   ºAutor  ³ Toni Aguiar        º Data ³  24/09/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de acompanhamento de SC´s                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACOM>Miscelânea                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function COMM003()
Local   oButton1,oButton2,oButton3,oButton4,oButton5,oButton7,oButton8
Local   oGroup1,oGroup2,oGroup3
Local   nOp:=0          
Private oSay1, oSay2
Private oFont     := TFont():New("Arial",9,18,,.T.,,,,,.F.) // negrito (.T.)  
Private oRadMenu1
Private nRadMenu1 := 8
Private nControle := 0
Private oMarkbrow
Private cFiltro1,cFiltro2,cFiltro3,cFiltro4,cFiltro5,cFiltro6,cFiltro7,cFiltro8       
Static  oDlg 

SetKey (VK_F12,{|a,b| MsgRun( "Carregando...",,{||fDadosPed()})})
    
DEFINE MSDIALOG oDlg TITLE "Acompanhamento de SC" FROM 000, 000  TO 600, 1250 COLORS 0, 16777215 PIXEL

    @ 090, 004 GROUP oGroup1 TO 285, 617 PROMPT "SC´s" OF oDlg COLOR 0, 16777215 PIXEL
    @ 001, 004 GROUP oGroup2 TO 090, 100 PROMPT "Opções" OF oDlg COLOR 0, 16777215 PIXEL      
    @ 001, 196 GROUP oGroup3 TO 090, 617 PROMPT "Dados" OF oDlg COLOR 0, 16777215 PIXEL

    @ 012, 011 RADIO oRadMenu1 VAR nRadMenu1 ITEMS "Aguardando Aprovação","Aprovadas","Atendidas","Parcialmente Atendidas","Em Cotação","Eliminadas por Resíduo","Rejeitadas","Todas" SIZE 083, 068 OF oDlg COLOR 0, 16777215 PIXEL
    @ 072, 104 BUTTON oButton1 PROMPT "Executa"       SIZE 039, 015 OF oDlg ACTION (nOp:=1, MsgRun( "Processando... Aguarde!",,{||fExec()})) PIXEL
    @ 053, 104 BUTTON oButton2 PROMPT "Comprador"     SIZE 039, 015 OF oDlg ACTION (nOp:=2, U_fSelSC()) PIXEL
    //@ 053, 104 BUTTON oButton2 PROMPT "Comprador"     SIZE 039, 015 OF oDlg ACTION (nOp:=2, fAprComp()) PIXEL
    @ 035, 104 BUTTON oButton3 PROMPT "Visualiza"     SIZE 039, 015 OF oDlg ACTION (nOp:=3, MsgRun( "Aguarde... carregando a tela de visualização...",,{||fVisualSC1()})) PIXEL
    @ 001, 104 BUTTON oButton4 PROMPT "Sc/Comprad."   SIZE 039, 015 OF oDlg ACTION (nOp:=4, fSCComp()) PIXEL  
    @ 018, 104 BUTTON oButton4 PROMPT "Sair"          SIZE 039, 015 OF oDlg ACTION (nOp:=5, oDlg:End()) PIXEL 
    @ 001, 152 BUTTON oButton5 PROMPT "Relatorio SC"  SIZE 039, 015 OF oDlg ACTION (nOp:=6, MATR140()) PIXEL    
    @ 018, 152 BUTTON oButton5 PROMPT "Filtra Com."   SIZE 039, 015 OF oDlg ACTION (nOp:=7, fFilComp()) PIXEL
    //@ 035, 152 BUTTON oButton6 PROMPT "Filtra Sc"     SIZE 039, 015 OF oDlg PIXEL
    @ 035, 152 BUTTON oButton7 PROMPT "Limpa Filtros" SIZE 039, 015 OF oDlg ACTION (nOp:=8, fLimpaFil()) PIXEL
    @ 053, 152 BUTTON oButton8 PROMPT "Conhecimento"  SIZE 039, 015 OF oDlg ACTION (nOp:=9, MsgRun( "Carregando...",,{||fBConhec(SC1->C1_NUM)})) PIXEL
    @ 024, 221 SAY oSay1 PROMPT "" SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL
    @ 058, 221 SAY oSay2 PROMPT "" SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL
    
    /*
    @ 035, 152 BUTTON oButton6 PROMPT "Filtra Sc"     SIZE 039, 015 OF oDlg PIXEL
    @ 053, 152 BUTTON oButton7 PROMPT "Limpa Filtros" SIZE 039, 015 OF oDlg ACTION (nOp:=8, fLimpaFil()) PIXEL
    @ 072, 152 BUTTON oButton8 PROMPT "Conhecimento"  SIZE 039, 015 OF oDlg ACTION (nOp:=9, MsgRun( "Carregando...",,{||fBConhec(SC1->C1_NUM)})) PIXEL
    @ 024, 221 SAY oSay1 PROMPT "" SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL
    @ 058, 221 SAY oSay2 PROMPT "" SIZE 150, 024 OF oDlg COLORS 0, 16777215 PIXEL
    */ 
    If nOp=0 .Or. nOp=1
       fMSNewGe1()
    Endif
ACTIVATE MSDIALOG oDlg CENTERED

Return

// Monta e apresenta o browser
//------------------------------------------------
Static Function fMSNewGe1()
//------------------------------------------------
Local nX
Local aFields  := {"C1_NUM","C1_ITEM","C1_PRODUTO","C1_DESCRI","C1_QUANT","C1_VUNIT","C1_EMISSAO","C1_XPRIORI","C1_APROV","C1_OBS","C1_XNOMECP","C1_CC","C1_ITEMCTA","C1_CLVL","C1_SOLICIT","C1_CONTA"}
Local lInverte := .F.
Local cMark    := GetMark()
Local aBrwc    := {}
Local aRet     := {}
Static oMSNewGe1    

// Checa a permissão do usuário
PswOrder(2)           
If PswSeek(cUserName) 
   aRet := PswRet(1)
   If !(aRet[1][1] $ GetMv("MV_XCOMPRA"))   	// Checa se o usuário é o Gerente de Compras,
      cCpr:=aRet[1][1]                          // Caso não seja, atribui o código do comprador automaticamente, pois ele só poderá 
   Endif                                        // enxergar as suas SC´s.
Endif

// Define as propriedades dos campos
//DbSelectArea("SX3")
//SX3->(DbSetOrder(2))
For nX := 1 to Len(aFields)
   //If SX3->(DbSeek(aFields[nX]))
      AADD(aBrwc, {aFields[nX],,X3Titulo(aFields[nX]),X3Picture(aFields[nX])}) 
   //Endif
Next nX

// Carrega os dados conforme opção selecionada
CarregaDados()

oMarkbrow := MsSelect():New("SC1","",,aBrwc,@lInverte,@cMark,{98,08,280,612},,,oDlg)
//oMarkbrow := MsSelect():New("SC1","C1_ZZMARCA",,aBrwc,@lInverte,GetMark(,"SC1","C1_ZZMARCA"),{98,08,280,612},,,oDlg)
//oMarkbrow:oBrowse:blDBLClick:= {|| MsgRun( "Aguarde... carregando a tela de visualização...",,{ || fVisualSC1() } )}
Return

// Função de filtros para apresentação dos dados no Browser
//----------------------------------------------------------
Static Function CarregaDados(cCpr)                              
//----------------------------------------------------------  
Local cCodi

dbSelectArea("SC1")
SC1->(DBClearFilter())
SC1->(dbSetOrder(1))
SC1->(dbGoTop())

If cCpr=NIL .Or. cCpr=""
   cFiltro1 := "SC1->C1_FILIAL = xFilial('SC1') .And. SC1->C1_QUJE = 0 .And. Empty(SC1->C1_COTACAO) .And. SC1->C1_APROV = 'B' .And. Empty(SC1->C1_RESIDUO)" 
   cFiltro2 := "SC1->C1_FILIAL = xFilial('SC1') .And. SC1->C1_QUJE = 0 .And. Empty(SC1->C1_COTACAO) .And. SC1->C1_APROV = 'L' .And. Empty(SC1->C1_RESIDUO)"
   cFiltro3 := "SC1->C1_FILIAL = xFilial('SC1') .And. (SC1->C1_QUJE > 0 .And. !Empty(SC1->C1_PEDIDO) .And. Empty(SC1->C1_RESIDUO)) .OR. "+;
               "(SC1->C1_QUJE = 0 .And. Empty(SC1->C1_PEDIDO) .And. Empty(SC1->C1_RESIDUO) .AND. !Empty(SC1->C1_FLAGGCT) )" 
   cFiltro4 := "SC1->C1_FILIAL = xFilial('SC1') .And. SC1->C1_QUJE > 0 .And. SC1->C1_QUJE < SC1->C1_QUANT .AND. !Empty(SC1->C1_PEDIDO) .And. Empty(SC1->C1_RESIDUO)"
   cFiltro5 := "SC1->C1_FILIAL = xFilial('SC1') .And. SC1->C1_TPSC != '2' .And. SC1->C1_QUJE = 0 .And. !Empty(SC1->C1_COTACAO) .And. SC1->C1_IMPORT<>'S' "
   cFiltro6 := "SC1->C1_FILIAL = xFilial('SC1') .And. !Empty(C1_RESIDUO)"
   cFiltro7 := "SC1->C1_FILIAL = xFilial('SC1') .And. SC1->C1_QUJE = 0 .And. SC1->C1_APROV = 'R' .And. (Empty(SC1->C1_COTACAO) .Or. SC1->C1_COTACAO = 'IMPORT')"
   cFiltro8 := "SC1->C1_FILIAL = xFilial('SC1')"
Else
   cCodi:=Posicione("SY1",3,xFilial("SY1")+cCpr,"Y1_COD")
   cFiltro1 := "SC1->C1_FILIAL = xFilial('SC1') .And. SC1->C1_QUJE = 0 .And. Empty(SC1->C1_COTACAO) .And. SC1->C1_APROV = 'B' .And. Empty(SC1->C1_RESIDUO) .And. SC1->C1_CODCOMP=cCodi" 
   cFiltro2 := "SC1->C1_FILIAL = xFilial('SC1') .And. SC1->C1_QUJE = 0 .And. Empty(SC1->C1_COTACAO) .And. SC1->C1_APROV = 'L' .And. Empty(SC1->C1_RESIDUO) .And. SC1->C1_CODCOMP=cCodi" 
   cFiltro3 := "SC1->C1_FILIAL = xFilial('SC1') .And. (SC1->C1_QUJE > 0 .And. !Empty(SC1->C1_PEDIDO) .And. Empty(SC1->C1_RESIDUO) .And. SC1->C1_CODCOMP=cCodi) .OR. "+;
               "(SC1->C1_QUJE = 0 .And. Empty(SC1->C1_PEDIDO) .And. Empty(SC1->C1_RESIDUO) .AND. !Empty(SC1->C1_FLAGGCT))"  
   cFiltro4 := "SC1->C1_FILIAL = xFilial('SC1') .And. SC1->C1_QUJE > 0 .And. SC1->C1_QUJE < SC1->C1_QUANT .AND. !Empty(SC1->C1_PEDIDO) .And. Empty(SC1->C1_RESIDUO) .And. SC1->C1_CODCOMP=cCodi" 
   cFiltro5 := "SC1->C1_FILIAL = xFilial('SC1') .And. SC1->C1_TPSC != '2' .And. SC1->C1_QUJE = 0 .And. !Empty(SC1->C1_COTACAO) .And. SC1->C1_IMPORT<>'S' .And. SC1->C1_CODCOMP=cCodi" 
   cFiltro6 := "SC1->C1_FILIAL = xFilial('SC1') .And. !Empty(C1_RESIDUO) .And. SC1->C1_CODCOMP=cCodi"
   cFiltro7 := "SC1->C1_FILIAL = xFilial('SC1') .And. SC1->C1_QUJE = 0 .And. SC1->C1_APROV = 'R' .And. SC1->C1_CODCOMP=cCodi .And. (Empty(SC1->C1_COTACAO) .Or. SC1->C1_COTACAO = 'IMPORT')" 
   cFiltro8 := "SC1->C1_FILIAL = xFilial('SC1') .And. SC1->C1_CODCOMP=cCodi" 
Endif

Do Case
Case nRadMenu1 = 1	// Aguardando Aprovação   
   SET FILTER TO &cFiltro1
Case nRadMenu1 = 2  // Aprovadas
   SET FILTER TO &cFiltro2
Case nRadMenu1 = 3  // Atendidas                           
   SET FILTER TO &cFiltro3
Case nRadMenu1 = 4  // Parcialmente Atendidas
   SET FILTER TO &cFiltro4
Case nRadMenu1 = 5  // Em Cotação
   SET FILTER TO &cFiltro5
Case nRadMenu1 = 6  // Eliminadas por Resíduos 
   SET FILTER TO &cFiltro6
Case nRadMenu1 = 7  // Rejeitadas  
   SET FILTER TO &cFiltro7
Case nRadMenu1 = 8
   SET FILTER TO &cFiltro8
EndCase  
Return(.T.)  

// Executa ação selecionada
//--------------------------
Static Function fExec()      
//--------------------------
Local cCpr := ""     

oSay2:cCaption:=""

// Pesquisa o código do usuário do comprador
If Alltrim(Left(oSay1:cCaption,3))<>""
   cCpr:=Posicione("SY1",1,xFilial("SY1")+Alltrim(Left(oSay1:cCaption,3)),"Y1_USER") // Traz vazio - "", ou o código do comprador atribuído no filtro pelo Gerente de Compras
Endif

CarregaDados(cCpr)
oMarkbrow:oBrowse:Refresh()
Return()                

// Seleciona SC´s para Atribui ao comprador
//------------------------------------------
//Static Function fSelSC1()  
//------------------------------------------
//Local aCodRet := {}
//Local cCodRet := ""

// Chama o browser com as SC´s para seleciona-las
//--fSelSCBrw( @aCodRet )   
//If Len(aCodRet)>0
//--If Len(aCodRet)>0
   //AEval( aCodRet, { |x| cCodRet += ( x + "/" ) } )
   //cCodRet := Left( cCodRet, Len( cCodRet ) - 1 )

   // Apresenta a lista com os compradores para atribuir as SC´s
//--  fAprComp(aCodRet)
//--EndIf            
//--Return
      
// Apresenta o browser para seleção de SC´s 
// para atribuir o comprador
//------------------------------------------
/*Static Function fSelSCBrw( aCodRet )
//------------------------------------------
Local aArea     := GetArea()
Local lRet		:= .T.
Local aBox		:= {}                        
Local nTam		:= TamSX3("C1_NUM")[1]
Local MvParDef	:= "" 
Local cCodComp  := ""
Local cTitulo := "Solicitação de Compras"

// Checa a permissão do usuário
PswOrder(2)           
//If PswSeek(cUserName) 
  // aRet := PswRet(1)
   //If !(aRet[1][1] $ GetMv("MV_XCOMPRA"))
   //   lRet:=.F.                          
   //   Aviso("Atenção!", "Usuário sem permissão...",{"Sair"})
   //Endif
//Endif

If lRet
   // Filtra os registros para apresntação no browser de marcação
   SC1->(dbGoTop())
   //Do Case
   //Case nRadMenu1 = 2  // Aprovadas
      SET FILTER TO ( SC1->C1_FILIAL = xFilial("SC1") .And. SC1->C1_QUJE = 0 .And. Empty(SC1->C1_COTACAO) .And. SC1->C1_APROV = "L" .And. Empty(SC1->C1_RESIDUO) )
   //OtherWise   
   //   Aviso("Atenção!", "Rotina específica para opção de SC Aprovadas",{"Sair"})
   //   lRet:=.F.  
   //EndCase
Endif

If lRet
   dbSelectArea("SC1")
   SC1->(dbSetOrder(1))
   SC1->(dbGoTop())
   Do While !SC1->(Eof())
      cCodComp := If(Empty(SC1->C1_CODCOMP), "xxx", SC1->C1_CODCOMP)
      AADD( aBox, SC1->(cCodComp+"| "+C1_PRODUTO+"| "+C1_DESCRI) )                  
      //_cQuant:= cValTochar(SC1->C1_QUANT)
      //_cEmis := Dtoc(SC1->C1_EMISSAO)
      //AADD( aBox, SC1->(C1_NUM+"| "+C1_XNOMECP+"| "+C1_ITEM+"| "+C1_PRODUTO+"| "+C1_DESCRI+"| "+_cQuant+"| "+_cEmis+"| "+C1_CC+"| "+C1_ITEMCTA+"| "+C1_CLVL+"| "+C1_SOLICIT) )   
       
      MvParDef += SC1->C1_NUM
      SC1->(dbSkip())
   Enddo

   Do While lRet
	  lRet := f_Opcoes(	@aCodRet,;		// uVarRet
						cTitulo,;		// cTitulo
							@aBox,;			// aOpcoes
						MvParDef,;		// cOpcoes
						,;			    // nLin1
						,;			    // nCol1
						,;				// l1Elem
						nTam,; 			// nTam
						Len( aBox ),;	// nElemRet
						.T.,;				// lMultSelect
						,;				// lComboBox
						,;				// cCampo
						,;				// lNotOrdena
						,;				// NotPesq
						.T.,;			// ForceRetArr
						 )				// F3
			
	   If lRet .And. Len( aCodRet ) == 0
	   	  MsgInfo("Selecione ao menos um item para atribuir o código do comprador..." ) 
	   Else
	      Exit
	   EndIf
   EndDo
Endif
RestArea( aArea )
Return lRet */

// Função que apresenta os compradores
//--------------------------------------
Static Function fAprComp(aCodRet)
//----------------------------------------
Local oBut
Local nOpc :=0
Local aArea:=GetArea()
Local cCodi:="" 
Public aCodRet:= aWBrowse1
Static oDlg2
nControle++

Do While .T.
   DEFINE MSDIALOG oDlg2 TITLE "Selecione o comprador para atribuir as SC´s" FROM 000, 000  TO 200, 500 COLORS 0, 16777215 PIXEL
     fDBTree1() 
     @ 079, 089 BUTTON oBut PROMPT "Ok" SIZE 065, 015 OF oDlg2  ACTION  (nOpc:=1, Processa({||fAtualizaCpr(cCodi:=oDBTree1:GetCargo(), aCodRet), "Processando..."})) PIXEL
   ACTIVATE MSDIALOG oDlg2 CENTERED
   
   If nOpc=1 .And. Left(cCodi,1)<>"#"
      Exit
   Endif
Enddo
RestArea(aArea)  
Return     

// Preenche os dados dos compradores na dbTree
//------------------------------------------------
Static Function fDBTree1()
//------------------------------------------------
Static oDBTree1                                                    

dbSelectArea("SY1")
SY1->(dbSetOrder(1))
  
DEFINE dbTRee oDBTree1 FROM 008, 008 TO 070, 239 OF oDlg2 CARGO
   dbADDTRee oDBTree1 PROMPT "Compradores" RESOURCE "GGG" CARGO "#999" // StrZero(nControle,4)
   SY1->(dbGoTop())
   Do While !SY1->(Eof())
      dbADDItem oDBTree1 PROMPT SY1->Y1_NOME RESOURCE "AAA" CARGO SY1->Y1_COD
      SY1->(dbSkip())
   Enddo
dbENDTree oDBTree1
Return 

// Grava o comprador selecionado nas SC´s selecionadas
//-----------------------------------------------------
Static Function fAtualizaCpr(cComp, aCodRet)
Local _nX  :=0
Local cNome:=Posicione("SY1",1,xFilial("SY1")+cComp,"Y1_NOME")
dbSelectArea("SC1") 
SC1->(dbSetOrder(1))

ProcRegua(Len(aWBrowse1))
For _nX:=1 To Len(aWBrowse1)
   IncProc()
   
   // pula a sequência se o proximo registro do aCodRet for item da mesma SC já processada
   // pois uma SC pode ter vários itens. 
   /*
   If _nX>1 
      cNumAnt:=aWBrowse1[_nX][-2]
      If aWBrowse1[_nX][2]==cNumAnt
         loop
      Endif
   Endif
   */
   // Atualiza o codigo do comprador na SC
  If aWBrowse1[_nX][1] == .T.  
   If SC1->(dbSeek(xFilial("SC1")+aWBrowse1[_nX][2]))
      Do While SC1->C1_FILIAL=xFilial("SC1") .And. aWBrowse1[_nX][2]=SC1->C1_NUM .And. !SC1->(Eof())
         RecLock("SC1",.F.)
         SC1->C1_CODCOMP := cComp
         SC1->C1_XNOMECP := cNome
         SC1->(MsUnLock())
         SC1->(dbSkip()) 
      Enddo
   Endif
  Endif
Next
Aviso("Atenção!","Atribuição Realizada com Sucesso!!!",{"Finalizar"})

oDlg2:End()
oDlg1:End()   

Return

// Visualiza a SC
//-----------------------------------
Static Function fVisualSC1()
//--------------------------------
dbSelectArea("SC1")
A110Visual("SC1",RecNo(),2)
Return

// Filtro para compradores
//--------------------------------------
Static Function fFilComp()
//----------------------------------------
Local oBut
Local nOpc :=0
Local aArea:=GetArea()
Local cCodi:=""
Static oDlg2

Do While .T.
   DEFINE MSDIALOG oDlg2 TITLE "Selecione o comprador para filtrar as SC´s" FROM 000, 000  TO 200, 500 COLORS 0, 16777215 PIXEL
     fDBTree1()                                                                                    

     @ 079, 089 BUTTON oBut PROMPT "Ok" SIZE 065, 015 OF oDlg2  ACTION  (nOpc:=1, Processa({||fFilSel(cCodi:=oDBTree1:GetCargo()), "Processando..."})) PIXEL
   ACTIVATE MSDIALOG oDlg2 CENTERED
   oSay1:oFont    := oFont
   oSay1:cCaption := cCodi+" - "+Posicione("SY1",1,xFilial("SY1")+cCodi,"Y1_NOME") 
   If nOpc=1 .And. Left(cCodi,1)<>"#"
      Exit
   Endif
Enddo
RestArea(aArea)  
fExec()
Return

Static Function fFilSel(cPar1)
oDlg2:End()     
Return          

// Limpa os filtros definidos pelo gerente de compras
//-----------------------------------------------------
Static Function fLimpaFil()
oSay1:cCaption:=""         
fExec()
Return

// Chama o banco de conhecimento
// Parametro: cPara1 - Número da SC
//-----------------------------------
Static Function fBConhec(cPara1)     
//-----------------------------------
//Local cExprFilTop := ""        
Local cGetArea    := GetArea()
Local cFiltra	  := "C1_FILIAL == '"+xFilial('SC1')+"' .And. C1_NUM=='"+cPara1+"'"
Private aIndexSC1 := {}
Private bFiltraBrw:= { || FilBrowse("SC1",@aIndexSC1,@cFiltra) }
Private cCadastro := "Conhecimento"
Private aRotina   := { {"Conhecimento","MsDocument",0,4},; 
                       {"Visualizar","u_fVSC1",0,2} }

dbSelectArea("SC1")
SC1->(DbClearFilter())
SC1->(dbGoTop())

EVAL(bFiltraBrw)
                
MBrowse(6,1,22,75,"SC1")
EndFilBrw("SC1",aIndexSC1)
RestArea(cGetArea)
fExec()
return  

User Function fVSC1()
fVisualSC1()
Return 

// Apresenta dados do pedido de compras
//---------------------------------------
Static Function fDadosPed()              
//---------------------------------------
Local _cQry
_cQry:="    SELECT C1_NUM, C1_PEDIDO, CNB_CONTRA FROM "+RetSqlName("SC1")+" SC1 "
_cQry+="LEFT JOIN "+RetSqlName("CNB")+" CNB ON CNB.CNB_FILIAL = SC1.C1_FILIAL AND CNB.CNB_NUMSC = SC1.C1_NUM AND CNB.D_E_L_E_T_<>'*' " 
_cQry+="     WHERE SC1.D_E_L_E_T_ <> '*' AND SC1.C1_FILIAL='"+xFilial("SC1")+"' AND SC1.C1_NUM='"+SC1->C1_NUM+"' " 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"SC1A",.T.,.T.)

oSay2:oFont    := oFont
oSay2:cCaption := "Pedido: "+If(Alltrim(SC1->C1_PEDIDO)="", "NÃO HÁ", SC1->C1_PEDIDO)+;
                  " / Contrato: "+If(Alltrim(SC1A->CNB_CONTRA)="", "NÃO HÁ", SC1A->CNB_CONTRA)
            
SC1A->(dbCloseArea())  
Return

// SC x Compradores
//--------------------------------------
Static Function fSCComp()
//----------------------------------------
Local oBut
Local nOpc :=0
Local aArea:=GetArea()
Local cCodi:=""
Local cQuery:= ""
Static oDlg2


Do While .T.
   DEFINE MSDIALOG oDlg2 TITLE "Selecione o comprador para filtrar as SC´s" FROM 000, 000  TO 200, 500 COLORS 0, 16777215 PIXEL
   fDBTree1()                                                                                    
   
    _cQuery:= "SELECT COUNT(C1_NUM) NUMSC FROM "+RetSqlName("SC1")+" WHERE C1_CODCOMP ='"+cCodi+"' AND D_E_L_E_T_ <> '*' "
    dbUseArea( .T. ,"TOPCONN",TCGenQry(,,_cQuery),"TRB", .T. )

    DbSelectArea("TRB")
    While !TRB->(Eof())
    _nSc:= TRB->NUMSC
    TRB->(dbSkip())
    Enddo
   TRB->(dbCloseArea())   


   cQuery:= " SELECT COUNT(C1_NUM) NUMSC FROM "+RetSqlName("SC1")+" WHERE C1_QUJE = 0 AND C1_COTACAO = '' 
   cQuery+= " AND C1_APROV = 'L' AND C1_RESIDUO = '' AND   D_E_L_E_T_ <> '*' "
    dbUseArea( .T. ,"TOPCONN",TCGenQry(,,cQuery),"TRB", .T. )

    DbSelectArea("TRB")
    While !TRB->(Eof())
    _nSc1:= TRB->NUMSC
    TRB->(dbSkip())
    Enddo
   TRB->(dbCloseArea())   



   @ 079, 089 BUTTON oBut PROMPT "Ok" SIZE 065, 015 OF oDlg2  ACTION  (nOpc:=1, Processa({||fFilSel(cCodi:=oDBTree1:GetCargo()), "Processando..."})) PIXEL
   ACTIVATE MSDIALOG oDlg2 CENTERED
   oSay1:oFont    := oFont
   //oSay1:cCaption := cCodi+" - "+Posicione("SY1",1,xFilial("SY1")+cCodi,"Y1_NOME") 
   oSay1:cCaption  := "Quantidade de SC : "+ cValtochar(_nSc1)+"                                                  Quantidade SC x Comprador : "+ cValtochar(_nSc)
        
   If nOpc=1 .And. Left(cCodi,1)<>"#"
      Exit
   Endif
Enddo
RestArea(aArea)  
fExec()
Return  

User Function fSelSC()                        
Local oButton1
//Local aArea     := GetArea()
//Local lRet		:= .T.
//Local MvParDef	:= "" 
//Local cCodComp  := ""
//Local cTitulo := "Solicitação de Compras"
Static oDlg1

DEFINE MSDIALOG oDlg1 TITLE "Solicitação de Compras" FROM 000, 000  TO 500, 1000 COLORS 0, 16777215 PIXEL

     fWBrowse1()
     @ 228, 317 BUTTON oButton1 PROMPT "Atualizar" SIZE 075, 016 OF oDlg1 Action fAprComp() PIXEL 
     @ 228, 417 BUTTON oButton1 PROMPT "Bloquear " SIZE 075, 016 OF oDlg1 Action U_FRejeicao()PIXEL

ACTIVATE MSDIALOG oDlg1 CENTERED
Return

//------------------------------------------------ 
Static Function fWBrowse1()         
//------------------------------------------------ 
Local oOk := LoadBitmap( GetResources(), "LBOK")
Local oNo := LoadBitmap( GetResources(), "LBNO")
Local oWBrowse1
Local lRet		:= .T.
Local cCodComp  := ""
Public aWBrowse1 := {}
   // Insert items here 
   If lRet
   // Filtra os registros para apresntação no browser de marcação
    _cQuery:= "    SELECT * FROM "+RetSqlName("SC1")+" SC1 "
    _cQuery+= "INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_COD=SC1.C1_PRODUTO AND SB1.D_E_L_E_T_<>'*'"
    _cQuery+= "     WHERE SC1.C1_FILIAL='"+xFilial("SC1")+"' AND SC1.C1_QUJE = 0 AND SC1.C1_COTACAO = '' AND SC1.C1_APROV = 'L' AND SC1.C1_RESIDUO = '' "
    _cQuery+= "           AND SC1.D_E_L_E_T_<>'*' "
    _cQuery+= "  ORDER BY C1_NUM,C1_ITEM"
    dbUseArea(.T., 'TOPCONN' ,TCGenQry(,,_cQuery), 'TRB' ,.F.,.T.)
    
    dbselectArea("TRB")
    While !TRB->(eof())
       cCodComp := If(Empty(SC1->C1_CODCOMP), "xxx", SC1->C1_CODCOMP)
       Aadd(aWBrowse1,{.F.,;
                       TRB->C1_NUM,;
                       TRB->C1_ITEM,;
                       TRB->C1_PRODUTO,;
                       TRB->B1_ESPECIF,;
                       TRB->C1_QUANT,;
                       TRB->C1_VUNIT,;
                       STOD(TRB->C1_EMISSAO),;
                       TRB->C1_XPRIORI,;
                       TRB->C1_APROV,;
                       TRB->C1_OBS,;
                       TRB->C1_XNOMECP,;
                       TRB->C1_CC,;
                       TRB->C1_ITEMCTA,;
                       TRB->C1_CLVL,;
                       TRB->C1_SOLICIT,;
                       TRB->C1_CONTA})
       TRB->(dbSkip())
    Enddo      
       TRB->(dbCloseArea())
   Endif
    @ 002, 002 LISTBOX oWBrowse1 Fields HEADER "","Numero SC ","Item","Produto ","Descricao","Quantidade","Prc Estimado","Emissao","Prioridade","Status SC","Observacao","Comprador","C.Custo","Item Conta","Classe","Solicitante","Conta Contab" SIZE 492, 220 OF oDlg1 PIXEL ColSizes 50,50
    oWBrowse1:SetArray(aWBrowse1)
    oWBrowse1:bLine := {|| {;
      If(aWBrowse1[oWBrowse1:nAT,1],oOk,oNo),;
      aWBrowse1[oWBrowse1:nAt,2],;
      aWBrowse1[oWBrowse1:nAt,3],;
      aWBrowse1[oWBrowse1:nAt,4],;
      aWBrowse1[oWBrowse1:nAt,5],;
      aWBrowse1[oWBrowse1:nAt,6],;
      aWBrowse1[oWBrowse1:nAt,7],;
      aWBrowse1[oWBrowse1:nAt,8],;
      aWBrowse1[oWBrowse1:nAt,9],;
      aWBrowse1[oWBrowse1:nAt,10],;
      aWBrowse1[oWBrowse1:nAt,11],;
      aWBrowse1[oWBrowse1:nAt,12],;
      aWBrowse1[oWBrowse1:nAt,13],;
      aWBrowse1[oWBrowse1:nAt,14],;
      aWBrowse1[oWBrowse1:nAt,15],;
      aWBrowse1[oWBrowse1:nAt,16],;
      aWBrowse1[oWBrowse1:nAt,17];
    }}
    // DoubleClick event
    oWBrowse1:bLDblClick := {|| aWBrowse1[oWBrowse1:nAt,1] := !aWBrowse1[oWBrowse1:nAt,1],;
      oWBrowse1:DrawSelect()}

Return      

User Function FRejeicao()
Local oButton1
Local oMultiGe1
Private cMultiGe1 := Space(100)
Static oDlgx

If MsgYesNo("Tem certeza que deseja bloquear as SC´s?")
   DEFINE MSDIALOG oDlgx TITLE "Rejeição de SC. Informe o Motivo" FROM 000, 000  TO 200, 300 COLORS 0, 16777215 PIXEL

       @ 009, 006 GET oMultiGe1 VAR cMultiGe1 OF oDlgx MULTILINE SIZE 128, 066 COLORS 0, 16777215 HSCROLL PIXEL
       @ 079, 036 BUTTON oButton1 PROMPT "Finalizar " SIZE 070, 014 OF oDlgx ACTION U_UpdSCR() PIXEL

   ACTIVATE MSDIALOG oDlgx CENTERED
Endif
Return    

User Function UpdScr()
Local _nX  :=0    
Local _cUser:= RetCodUsr()  
Local _nultimo:= 0
Local _nRecDBm:= 0
Local _cNumPc := ""

dbSelectArea("SCR") 
SCR->(dbSetOrder(1)) 

_nUltimo:= SCR->(LASTREC())

dbSelectArea("SC1") 
SC1->(dbSetOrder(1))

DbSelectArea("DBM")
DBM->(dbSetOrder(2))

_nRecDBm:= SCR->(LASTREC())

ProcRegua(Len(aWBrowse1))
For _nX:=1 To Len(aWBrowse1)
  IncProc()

  If aWBrowse1[_nX][1] == .T.

     // Checa se o item já está bloqueado
     // quando há item na DBM com o item da sc = '9999', é poquê foi bloqueada pelo comprador na
     // rotina de deligenciamento de SC. Então pesquiso na tabela para nao gerar duplicidade.
     If !DBM->(dbSeek(xFilial("DBM")+"SC"+PADR(aWBrowse1[_nX][2],TamSX3("DBM_NUM")[1])+"9999"))

        _cQuery:=""       
        _cQuery:= "Select top(1) CR_NUM,* From "+RetSqlName("SCR")+" Where CR_NUM ='"+aWBrowse1[_nX][2]+"' and CR_TIPO = 'SC' and D_E_L_E_T_ <> '*' "
        DbUseArea(.T., 'TOPCONN' ,TCGenQry(,,_cQuery), 'TRB' ,.F.,.T.)
	     DBSelectArea("TRB")
	     Do While !TRB->(Eof())       
	
           RecLock("SCR",.T.)
           SCR->CR_FILIAL  := TRB->CR_FILIAL
           SCR->CR_NUM     := TRB->CR_NUM
           SCR->CR_TIPO    := "SC"
           SCR->CR_USER    := _cUser  // Código do Usuário
           SCR->CR_OBS     := cMultiGe1
           SCR->CR_APROV   := ""      // Código do Aprovador 
           SCR->CR_GRUPO   := ""      // Código do Grupo de aprovação 
           SCR->CR_ITGRP   := ""      // Item de aprovação                               
           SCR->CR_NIVEL   := "99"    // Nível de aprovação 
           SCR->CR_STATUS  := "04"    // Bloqueado 
           SCR->CR_EMISSAO := STOD(TRB->CR_EMISSAO)
           SCR->CR_TOTAL   := TRB->CR_TOTAL
           SCR->CR_PRAZO   := STOD(TRB->CR_PRAZO)
           SCR->CR_AVISO   := STOD(TRB->CR_AVISO)
           SCR->CR_ESCALON := .F.
           SCR->CR_ESCALSP := .F.
           SCR->(MsUnLock())
           TRB->(dbskip())
        Enddo
        TRB->(dbCloseArea())

        _cQuery:=""
        _cQuery:= "Select top(1) DBM_NUM,* From "+RetSqlName("DBM")+" Where DBM_NUM ='"+aWBrowse1[_nX][2]+"' and DBM_TIPO = 'SC' and D_E_L_E_T_ <> '*' "
        DbUseArea(.T., 'TOPCONN' ,TCGenQry(,,_cQuery), 'TRB' ,.F.,.T.)
	     DBSelectArea("TRB")
	     Do While !TRB->(Eof())   

           RecLock("DBM",.T.)
           DBM->DBM_FILIAL := TRB->DBM_FILIAL
           DBM->DBM_NUM    := TRB->DBM_NUM
           DBM->DBM_TIPO   := "SC"
           DBM->DBM_ITEM   := "9999"   
           DBM->DBM_USER   := _cUser  // Código do Usuário
           DBM->DBM_APROV  := "" 
           DBM->DBM_USAPRO := "" // Código do Aprovador 
           DBM->DBM_GRUPO  := "" // Código do Grupo de aprovação 
           DBM->DBM_ITGRP  := "" // Item de aprovação                               
           DBM->DBM_VALOR  := TRB->DBM_VALOR
           DBM->(MsUnLock())

           TRB->(dbSkip())
        EndDo
        TRB->(dbCloseArea())
     Endif
  Endif
Next                          

_cNumPc=""   
For _nX:=1 To Len(aWBrowse1)
    If _cNumPc = aWBrowse1[_nX][2] // Permite executar o processo em apenas 1 item da SC no browser de seleção.
       Loop
    Endif    
    _cNumPc:=aWBrowse1[_nX][2]

	If aWBrowse1[_nX][1] == .T.
		_cExec1:= " UPDATE "+RetSqlName("SC1")+" SET C1_APROV = 'B' WHERE C1_FILIAL = '"+xFilial("SC1")+"' AND C1_NUM = '"+aWBrowse1[_nX][2]+"'  AND D_E_L_E_T_ <> '*' "   
   
       nStatus1 := TCSqlExec(_cExec1)
       if (nStatus1 < 0)
         MsgAlert("TCSQLError() " + TCSQLError())
       endif
	Endif
Next

Aviso("Atenção!","Operação de Bloqueio Realizado com Sucesso!!!",{"Finalizar"})

oDlgx:End()
oDlg1:End()   
Return
