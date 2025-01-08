#INCLUDE "TOTVS.CH" 
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATA161.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} ANewMapCot
Função que efetua a montagem da tela de mapa de cotação
@author antenor.silva
@since 28/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
User Function NewMapCot()

Local aArea    := GetArea()
Local aAreaSC8 := SC8->(GetArea())

Local oDlg 

Local aItens		:= {}
Local aPropostas	:= {}
Local aItensC		:= {"Pedido de Compra","Contrato"}//"Pedido de Compra"//"Contrato"

Local cTpDoc 		:= If(Val(SC8->C8_TPDOC)== 1,"Pedido de Compra","Contrato")//"Pedido de Compra"//"Contrato"

Local nTpDoc		

Local oSize		:= FWDefSize():New(.T.)
Local lOk			:= .F.
Local lContinua	:= .T.
Local aGrpComp	:= {}
Local lRestCom	:= SuperGetMv("MV_RESTCOM",.F.,"N")=="S"
Local lMT161Ok	:= .F. 

PRIVATE cCadastro := "Análise de Cotação" //"Análise de Cotação"

//aCoors := FWGetDialogSize(oMainWnd)

//Valida se usuario tem permissão para fazer a analise
If lRestcom .And. !Empty(SC8->C8_GRUPCOM) .And. !VldAnCot(__cUserId,SC8->C8_GRUPCOM)
	Aviso("Acesso Restrito","O  acesso  e  a utilizacao desta rotina e destinada apenas aos usuarios pertencentes ao grupo de compras :"+SC8->C8_GRUPCOM+ "com direito de analise de cotacao.",{"Voltar"},2) //"Acesso Restrito"###"O  acesso  e  a utilizacao desta rotina e destinada apenas aos usuarios pertencentes ao grupo de compras : "###". com direito de analise de cotacao. "###"Voltar"
	lContinua := .F.
EndIf

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Iniciar lancamento do PCO                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PcoIniLan("000051")
	PcoIniLan("000052")

	DEFINE MSDIALOG oDlg TITLE cCadastro FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL
	
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||Iif(VALIDAOK(aPropostas),(lOk := .T.,aItens:=aClone(aItens) ,aPropostas:=aClone(aPropostas),oDlg:End()),.T.)},{||lOk:= .F., oDlg:End()}),ConstLayer(oDlg, @aItens, @aPropostas,@aItensC,@cTpDoc))
	
	If lOk
		nTpDoc := aScan(aItensC,{|x| x == cTpDoc})
		U_ANewGerDoc(aItens,aPropostas,nTpDoc) //Efetua a geração do pedido de compra ou contrato
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza processo de lancamento do PCO                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PcoFinLan("000051")
	PcoFinLan("000052")
	PcoFreeBlq("000051")
	PcoFreeBlq("000052")
	
Endif

SetKey( VK_F4,{||NIL} )
SetKey( VK_F5,{||NIL} )
SetKey( VK_F6,{||NIL} )
SetKey( VK_F7,{||NIL} )

RestArea(aArea)
RestArea(aAreaSC8)

Return Nil

Static Function ConstLayer(oDlg, aItens, aPropostas,aItensC,cTpDoc)

Local oFWLayer
Local oPanel0
Local oPanel1
Local oPanel2
Local oPanel3
Local oBrowse1
Local oBrowse2
Local oBrowse3
Local oVlrFinal

Local aCoors		:= {}

Local dDataVld 	:= SC8->C8_VALIDA
Local cCotacao 	:= SC8->C8_NUM

Local cFor1		:= ''
Local cFor2		:= ''
Local cCondPag1	:= SC8->C8_COND
Local cCondPag2	:= Space(30)
Local cTpFrete1	:= Space(30)
Local cTpFrete2	:= Space(30)

Local nVlrFinal		:= 0
Local nPag			:= 1
Local nNumPag		:= 0
Local nProp1		:= 0
Local nProp2		:= 0
Local nVlTot1		:= 0
Local nVlTot2		:= 0
Local nI			:= 0
Local nOpcA			:= 0

Local nPercent1
Local nPercent2
Local nAltura

Local lSugere		:= MV_PAR03==1


Setkey( VK_F4,{||U_ANewHisPro(aItens[oBrowse1:At()][1])})
Setkey( VK_F5,{||U_ANewMovPag(aPropostas, @oBrowse2, @oBrowse3, IIF(nPag > 1,--nPag,1), @cFor1, @nProp1, @cCondPag1, @cTpFrete1, @nVlTot1,@cFor2, @nProp2, @cCondPag2, @cTpFrete2, @nVlTot2, @oPanel3,oBrowse1)})
Setkey( VK_F6,{||U_ANewMovPag(aPropostas, @oBrowse2, @oBrowse3, IIF(Len(aPropostas) <= nPag,nPag,++nPag), @cFor1, @nProp1, @cCondPag1, @cTpFrete1, @nVlTot1,@cFor2, @nProp2, @cCondPag2, @cTpFrete2, @nVlTot2, @oPanel3,oBrowse1)})
SetKey( VK_F7,{||U_ANewHisForn(aPropostas[nPag][1][1][1],aPropostas[nPag][1][1][2])})
SetKey( VK_F8,{||U_ANewHisForn(aPropostas[nPag][2][1][1],aPropostas[nPag][2][1][2])})

ANewProp(cCotacao, @aItens, @aPropostas ) //Efetua a montagem do array para ser usado na interface do Mapa de Cotação

nNumPag := Len(aPropostas)

oPanel0:= tPanel():New(0,0,,oDlg,,,,,,0,0)
oPanel0:Align := CONTROL_ALIGN_ALLCLIENT

// Cria instancia do fwlayer
oFWLayer := FWLayer():New()

// Inicializa componente passa a Dialog criada,o segundo parametro é para 
// criação de um botao de fechar utilizado para Dlg sem cabeçalho 		  
oFWLayer:Init(oPanel0,.F./*,.T.*/)

oPanel0:ReadClientCoors(.T.,.T.)
nAltura := oPanel0:nHeight

nPercent1 := (210 * 100) / nAltura
nPercent2 := 100 - nPercent1 

// Efetua a montagem das linhas das telas

oFWLayer:addLine("LINHA1",nPercent1,.T.)
oFWLayer:addLine("LINHA2",nPercent2,.F.)

// Efetua a montagem das colunas das telas
oFWLayer:AddCollumn("BOX1",34,.T.,"LINHA1")
oFWLayer:AddCollumn("BOX2",33,.T.,"LINHA1")
oFWLayer:AddCollumn("BOX3",33,.T.,"LINHA1")

oFWLayer:AddCollumn("BOX4",34,.T.,"LINHA2")
oFWLayer:AddCollumn("BOX5",33,.T.,"LINHA2")
oFWLayer:AddCollumn("BOX6",33,.T.,"LINHA2")

// Cria a window passando, nome da coluna onde sera criada, nome da window			 	
// titulo da window, a porcentagem da altura da janela, se esta habilitada para click,	
// se é redimensionada em caso de minimizar outras janelas e a ação no click do split 
oFWLayer:AddWindow("BOX1","oPanel1",STR0013	,100,.F.,.T.,,"LINHA1",{ || })//"Dados da Cotação"
oFWLayer:AddWindow("BOX2","oPanel2",STR0014	,100,.F.,.T.,,"LINHA1",{ || })//"Dados da Proposta"
oFWLayer:AddWindow("BOX3","oPanel3",STR0014	,100,.F.,.T.,,"LINHA1",{ || })//"Dados da Proposta"

oFWLayer:AddWindow("BOX4","oPanel4",STR0016			,100,.F.,.T.,,"LINHA2",{ || })//"Produtos"
oFWLayer:AddWindow("BOX5","oPanel5",STR0017	,100,.F.,.T.,,"LINHA2",{ || })//"Item da Proposta"
oFWLayer:AddWindow("BOX6","oPanel6",STR0017	,100,.F.,.T.,,"LINHA2",{ || })//"Item da Proposta"

// Retorna o objeto do painel da Janela
oPanel1 := oFWLayer:GetWinPanel("BOX1","oPanel1","LINHA1")
oPanel2 := oFWLayer:GetWinPanel("BOX2","oPanel2","LINHA1")
oPanel3 := oFWLayer:GetWinPanel("BOX3","oPanel3","LINHA1")

oPanel4 := oFWLayer:GetWinPanel("BOX4","oPanel4","LINHA2")
oPanel5 := oFWLayer:GetWinPanel("BOX5","oPanel5","LINHA2")
oPanel6 := oFWLayer:GetWinPanel("BOX6","oPanel6","LINHA2")

// Dados da cotação
@ 7,2 SAY RetTitle("C8_NUM") OF oPanel1 PIXEL
@ 5,37 MSGET cCotacao SIZE 30,10 WHEN .F. OF oPanel1 PIXEL

@ 27,2 SAY RetTitle("C8_VALIDA") OF oPanel1 PIXEL
@ 25,37 MSGET dDataVld SIZE 50,10 WHEN .F. OF oPanel1 PIXEL

@ 47,2 SAY STR0074  OF oPanel1 PIXEL //"Valor Final"
@ 45,37 MSGET oVlrFinal VAR nVlrFinal SIZE 50,10 WHEN .F. PICTURE PesqPict("SC8","C8_TOTAL") OF oPanel1 PIXEL

@ 7,96 SAY RetTitle("C8_TPDOC") OF oPanel1 PIXEL
@ 5,120 MSCOMBOBOX cTpDoc ITEMS aItensC SIZE 68,14 WHEN aScan(aItens,{|x| x[9] == .F.  }) >0 OF oPanel1 PIXEL

@ 27,96 SAY STR0019 OF oPanel1 PIXEL//'Página'
@ 25,120 MSGET nPag SIZE 20,10 VALID nPag > 0 .And. nPag <= nNumPag .And. ;
			U_ANewMovPag(aPropostas, @oBrowse2, @oBrowse3, nPag, @cFor1, @nProp1, @cCondPag1, @cTpFrete1, @nVlTot1,@cFor2, @nProp2, @cCondPag2, @cTpFrete2, @nVlTot2,@oPanel3,oBrowse1);
				 OF oPanel1 PIXEL

@ 27,143 SAY STR0020 OF oPanel1 PIXEL//'/'
@ 25,148 MSGET nNumPag SIZE 20,10 WHEN .F. OF oPanel1 PIXEL

TButton():Create(oPanel1,63,2,STR0021,{||U_ANewHisPro(aItens[oBrowse1:At()][1])},85,13,,,,.T.,,STR0021,,,,)//STR0022//'Histórico do Produto (F4)'
TButton():Create(oPanel1,45,120,STR0023,{|| U_ANewMovPag(aPropostas, @oBrowse2, @oBrowse3, IIF(nPag > 1,--nPag,1), @cFor1, @nProp1, @cCondPag1, @cTpFrete1, @nVlTot1,@cFor2, @nProp2, @cCondPag2, @cTpFrete2, @nVlTot2, @oPanel3,oBrowse1 )},67,13,,,,.T.,,STR0023,,,,)//STR0024//'Página Anterior (F5)'
TButton():Create(oPanel1,63,120,STR0025 ,{|| U_ANewMovPag(aPropostas, @oBrowse2, @oBrowse3, IIF(Len(aPropostas) <= nPag,nPag,++nPag), @cFor1, @nProp1, @cCondPag1, @cTpFrete1, @nVlTot1,@cFor2, @nProp2, @cCondPag2, @cTpFrete2, @nVlTot2, @oPanel3,oBrowse1)},67,13,,,,.T.,,STR0025,,,,)//STR0026//'Próxima Página (F6)'

// Dados do PRIMEIRO fornecedor na tela
	if !Empty(aPropostas[1][1][1])
		cFor1 		:= aPropostas[1][1][1][3]
		nProp1		:= aPropostas[1][1][1][4]
		cCondPag1	:= aPropostas[1][1][1][5]
		cTpFrete1	:= U_ANewDscF(aPropostas[1][1][1][6])
		nVlTot1	:= aPropostas[1][1][1][7] 
	Else
		oPanel3:lVisible := .F.
		oPanel6:lVisible := .F.
		SetKey( VK_F8,{||NIL} )
	EndIf

@ 7,2 SAY STR0027 OF oPanel2 PIXEL//'Fornecedor'
@ 5,35 MSGET cFor1 SIZE 153,10 WHEN .F. OF oPanel2 PIXEL

@ 27,2 SAY STR0028 OF oPanel2 PIXEL//'Proposta'
@ 25,35 MSGET nProp1 SIZE 30,10 WHEN .F. OF oPanel2 PIXEL

@ 47,2 SAY STR0029	OF oPanel2 PIXEL//'Tp. Frete'
@ 45,35 MSGET cTpFrete1 SIZE 30,10 WHEN .F. OF oPanel2 PIXEL

@ 27,90 SAY STR0030 OF oPanel2 PIXEL//'Cond. Pagto'
@ 25,125 MSGET cCondPag1 SIZE 63,10 WHEN .F. OF oPanel2 PIXEL


@ 47,90 SAY STR0031 OF oPanel2 PIXEL//'Vl. Total'
@ 45,125 MSGET nVlTot1 SIZE 63,10 WHEN .F. PICTURE PesqPict("SC8","C8_TOTAL") OF oPanel2 PIXEL

TButton():Create(oPanel2,63,35,STR0032,{||U_ANewHisForn(aPropostas[nPag][1][1][1],aPropostas[nPag][1][1][2])},153,13,,,,.T.,,STR0032,,,,)//STR0033//'Histórico do Fornecedor (F7)'

// Dados do SEGUNDO fornecedor na tela
If !Empty(aPropostas[1,2,1])
	cFor2 		:= aPropostas[1][2][1][3]
	nProp2		:= aPropostas[1][2][1][4]
	cCondPag2	:= aPropostas[1][2][1][5]
	cTpFrete2	:= U_ANewDscF(aPropostas[1][2][1][6])
	nVlTot2	:= aPropostas[1][2][1][7]  
	SetKey(VK_F8,{||U_ANewHisForn(aPropostas[nPag][2][1][1],aPropostas[nPag][2][1][2])})	
Else
	oPanel3:lVisible := .F.
	oPanel6:lVisible := .F.
	SetKey( VK_F8,{||NIL} )
EndIf

@ 7,2 SAY STR0027 OF oPanel3 PIXEL//'Fornecedor'
@ 5,35 MSGET cFor2 SIZE 153,10 WHEN .F. OF oPanel3 PIXEL

@ 27,2 SAY STR0028 OF oPanel3 PIXEL//'Proposta'
@ 25,35 MSGET nProp2 SIZE 30,10 WHEN	 .F. OF oPanel3 PIXEL

@ 47,2 SAY STR0029	OF oPanel3 PIXEL//'Tp. Frete'
@ 45,35 MSGET cTpFrete2 SIZE 30,10 WHEN .F. OF oPanel3 PIXEL

@ 27,90 SAY STR0030 OF oPanel3 PIXEL//'Cond. Pagto'
@ 25,125 MSGET cCondPag2 SIZE 63,10 WHEN .F. OF oPanel3 PIXEL

@ 47,90 SAY STR0031 OF oPanel3 PIXEL//'Vl. Total'
@ 45,125 MSGET nVlTot2 SIZE 63,10 WHEN .F. PICTURE PesqPict("SC8","C8_TOTAL") OF oPanel3 PIXEL

TButton():Create(oPanel3,63,35,STR0039,{||U_ANewHisForn(aPropostas[nPag][2][1][1],aPropostas[nPag][2][1][2])},153,13,,,,.T.,,STR0039,,,,)//STR0040//'Histórico do Fornecedor (F8)'

// Carga de dados dos produtos
DEFINE FWBROWSE oBrowse1 DATA ARRAY ARRAY aItens NO CONFIG  NO REPORT NO LOCATE OF oPanel4

ADD COLUMN oColumn DATA { || aItens[oBrowse1:At(),1] } TITLE STR0041 HEADERCLICK { || .T. } OF oBrowse1//"Cod. Produto"
ADD COLUMN oColumn DATA { || aItens[oBrowse1:At(),8] } TITLE STR0042 	HEADERCLICK { || .T. }	OF oBrowse1//"Descrição"
ADD COLUMN oColumn DATA { || aItens[oBrowse1:At(),3] } TITLE STR0043 PICTURE PesqPict("SC8","C8_QUANT") HEADERCLICK { || .T. } OF oBrowse1//"Quantidade"
ADD COLUMN oColumn DATA { || aItens[oBrowse1:At(),4] } TITLE STR0044 HEADERCLICK { || .T. } OF oBrowse1//"UM"
ADD COLUMN oColumn DATA { || aItens[oBrowse1:At(),5] } TITLE STR0045 HEADERCLICK { || .T. } OF oBrowse1//"Necessidade"
ADD COLUMN oColumn DATA { || aItens[oBrowse1:At(),6] } TITLE STR0046 HEADERCLICK { || .T. } OF oBrowse1//"Entrega"
ADD COLUMN oColumn DATA { || aItens[oBrowse1:At(),7] } TITLE STR0047 PICTURE PesqPict("SC8","C8_TOTAL") HEADERCLICK { || .T. } OF oBrowse1//"Valor Final"

oBrowse1:bOnMove := {|oBrowse,nMoveType,nCursorPos,nQtdLinha,nVisbleRow| U_ANewOnMove(oBrowse,nMoveType,nCursorPos,nQtdLinha,nVisbleRow,oBrowse1,oBrowse2,oBrowse3)}
oBrowse1:SetLineHeight(25)

ACTIVATE FWBROWSE oBrowse1

// Carga de dados da primeira proposta na tela
DEFINE FWBROWSE oBrowse2 DATA ARRAY ARRAY aPropostas[nPag,1,2] NO CONFIG  NO REPORT NO LOCATE OF oPanel5
oBrowse2:AddMarkColumns( { || IIf( aPropostas[nPag,1,2,oBrowse2:At(),1], "AVGLBPAR1","" ) },;
						    { || ANewDesMark(nPag,1,oBrowse2:At(),@aPropostas,@aItens,oBrowse1,oBrowse2,oBrowse3,.F.),;
						    								nVlrFinal:= ANewCalTot(aItens),oVlrFinal:Refresh()},;
						    { || ANewMarkAll(nPag,1,@aPropostas,@aItens,oBrowse1,oBrowse2,oBrowse3),;
						    								nVlrFinal:= ANewCalTot(aItens),oVlrFinal:Refresh()})
ADD COLUMN oColumn DATA { || IIf(!Empty(aPropostas[nPag,1,2,oBrowse2:At(),2]),Transform(aPropostas[nPag,1,2,oBrowse2:At(),13], PesqPict("SC8","C8_PRECO")),'') } TITLE "Preco Unitario" SIZE 20 HEADERCLICK { || .T. } OF oBrowse2//'Valor Total'  //ismael junior 05/06/2019						    
ADD COLUMN oColumn DATA { || IIf(!Empty(aPropostas[nPag,1,2,oBrowse2:At(),2]),Transform(aPropostas[nPag,1,2,oBrowse2:At(),4], PesqPict("SC8","C8_TOTAL")),'') } TITLE STR0048 SIZE 20 HEADERCLICK { || .T. } OF oBrowse2//'Valor Total'
ADD COLUMN oColumn DATA { || aPropostas[nPag,1,2,oBrowse2:At(),5] } PICTURE PesqPict("SC8","C8_DATPRF") Type 'D' TITLE STR0046 SIZE 20 HEADERCLICK { || .T. } OF oBrowse2//'Entrega'
ADD COLUMN oColumn DATA {||'Memo'} PICTURE '@!' TITLE RetTitle("C8_OBS") SIZE 20 HEADERCLICK { || .T. } DOUBLECLICK {|| ShowBMemo(@aPropostas[nPag,1,2,oBrowse2:At(),6])}   OF oBrowse2

oBrowse2:bOnMove := {|oBrowse,nMoveType,nCursorPos,nQtdLinha,nVisbleRow| U_ANewOnMove(oBrowse,nMoveType,nCursorPos,nQtdLinha,nVisbleRow,oBrowse1,oBrowse2,oBrowse3)}
oBrowse2:SetLineHeight(25)
oBrowse2:SetBlkBackColor({|| IIf(Empty(aPropostas[nPag,1,2,oBrowse2:At(),5]), CLR_LIGHTGRAY, Nil) })

ACTIVATE FWBROWSE oBrowse2

// Carga de dados da segunda proposta na tela
DEFINE FWBROWSE oBrowse3 DATA ARRAY ARRAY aPropostas[nPag,2,2] NO CONFIG  NO REPORT NO LOCATE OF oPanel6
	oBrowse3:AddMarkColumns(	{ || IIf( !Empty(aPropostas[nPag,2,2]) .And. aPropostas[nPag,2,2,oBrowse3:At(),1], 'AVGLBPAR1','' ) },;
							   	{ || ANewDesMark(nPag,2,oBrowse3:At(),@aPropostas,@aItens,oBrowse1,oBrowse2,oBrowse3,.F.),;
							   								nVlrFinal:= ANewCalTot(aItens), oVlrFinal:Refresh()},;
								{ || ANewMarkAll(nPag,2,@aPropostas,@aItens,oBrowse1,oBrowse2,oBrowse3),;
															nVlrFinal:= ANewCalTot(aItens), oVlrFinal:Refresh()})

ADD COLUMN oColumn DATA { || IIf(!Empty(aPropostas[nPag,2,2]) .And. !Empty(aPropostas[nPag,2,2,oBrowse3:At(),2]),Transform(aPropostas[nPag,2,2,oBrowse3:At(),13], PesqPict("SC8","C8_PRECO")),'') } TITLE "Preco Unitario" SIZE 20 HEADERCLICK { || .T. } OF oBrowse3//'Valor UNITARIO' ISMAEL JUNIOR 05/06/2019															
ADD COLUMN oColumn DATA { || IIf(!Empty(aPropostas[nPag,2,2]) .And. !Empty(aPropostas[nPag,2,2,oBrowse3:At(),2]),Transform(aPropostas[nPag,2,2,oBrowse3:At(),4], PesqPict("SC8","C8_TOTAL")),'') } TITLE STR0048 SIZE 20 HEADERCLICK { || .T. } OF oBrowse3//'Valor Total'
ADD COLUMN oColumn DATA { || IIf(!Empty(aPropostas[nPag,2,2]),aPropostas[nPag,2,2,oBrowse3:At(),5],'') } PICTURE PesqPict("SC8","C8_DATPRF") TITLE STR0046 SIZE 20 HEADERCLICK { || .T. } OF oBrowse3//'Entrega'
ADD COLUMN oColumn DATA {||'Memo'} PICTURE '@!' TITLE RetTitle("C8_OBS") SIZE 20 HEADERCLICK { || .T. } DOUBLECLICK {|| ShowBMemo(@aPropostas[nPag,2,2,oBrowse3:At(),6])}   OF oBrowse3

oBrowse3:bOnMove := {|oBrowse,nMoveType,nCursorPos,nQtdLinha,nVisbleRow| U_ANewOnMove(oBrowse,nMoveType,nCursorPos,nQtdLinha,nVisbleRow,oBrowse1,oBrowse2,oBrowse3)}
oBrowse3:SetLineHeight(25)
oBrowse3:SetBlkBackColor({|| IIf(Empty(aPropostas[nPag,2,2,oBrowse3:At(),5]), CLR_LIGHTGRAY, Nil) })

ACTIVATE FWBROWSE oBrowse3

// -----------------------------------------------------------------------
// Sugestão do Vencedor
// -----------------------------------------------------------------------
If lSugere
	If MV_PAR05 == 0 .And. MV_PAR06 == 0 .And. MV_PAR07 == 0 
		Help("",1,"U_ANewCotVen",,"STR0084",4,1)	
	Else
		U_ANewCotVen(aItens,aPropostas,oBrowse1,oBrowse2,oBrowse3)
	EndIf
EndIf

nVlrFinal:= ANewCalTot(aItens)

oPanel1:Refresh()
oVlrFinal:Refresh() // Atualiza o campo Valor Final.

Return


//-------------------------------------------------------------------
/*{Protheus.doc} U_ANewOnMove
Função responsavel por atualizar cursor nas linhas do Browser
@author antenor.silva
@since 28/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
User Function ANewOnMove(oBrowse,nMoveType,nCursorPos,nQtdLinha,nVisbleRow,oBrowse1,oBrowse2,oBrowse3)

oBrowse1:OnMove(oBrowse1:oBrowse,nMoveType,nCursorPos,nQtdLinha,nVisbleRow)
oBrowse2:OnMove(oBrowse2:oBrowse,nMoveType,nCursorPos,nQtdLinha,nVisbleRow)
oBrowse3:OnMove(oBrowse3:oBrowse,nMoveType,nCursorPos,nQtdLinha,nVisbleRow)

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} ANewProp
Efetua montagem do array de tens para a grid fixa e o array para as propostas.

@author José Eulálio
@since 28/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
Static Function ANewProp(cNum, aItens, aPropostas )
Local nPag 		:= 1
Local nProp 		:= 1
Local nX 			:= 0
Local nPg 			:= 0
Local nNumPro 	:= 0
Local nY 			:= 1
Local nPosRef1 	:= 0
Local nPosRef2 	:= 0
Local nCusto 		:= ''
Local nPosRef 	:= 0
Local nPa 			:= 0
Local nPo 			:= 0

Local cPgto		:= ''
Local cQuery		:= ''
Local cCodRef 	:= ''
Local cMsg 		:= ''
Local cAtuPos 	:= ''

Local lWin 		:= .F.
Local lFim 		:= .F.
Local lGrdOk 		:= .F.

Local aRefImpos 	:= {}

Local nP     := 0
Local nR     := 0
Local nI     := 0
Local nDif   := 0
Local nPosId := 0

Local aPags   := {} // Armazena a pagina e proposta utilizada para cada fornecedor.
Local nArmPg  := 0 // Controle do AScan.
Local nUltPag := 0 // Ultima pagina utilizada por um fornecedor.
Local nUltPro := 0 // Ultima proposta utilizada por um fornecedor.

Local aDadosSC8 := {}

//Query que retorna quantidade de propostas
BeginSQL Alias "SC8PRO"			
	SELECT C8_FORNECE,C8_LOJA,C8_NUMPRO
	FROM %Table:SC8%
	WHERE %NotDel% AND
		C8_FILIAL = %xFilial:SC8% AND
		C8_NUM = %Exp:cNum%
	GROUP BY C8_FORNECE,C8_LOJA,C8_NUMPRO		
EndSQL
Do While SC8PRO->(!EOF())
	nNumPro += 1
	SC8PRO->(dbSkip())
EndDo
SC8PRO->(dbCloseArea())

//Query que organiza as cotações para o Array
cQuery := "SELECT C8_PRODUTO, "
cQuery += "R_E_C_N_O_ SC8REC, "
cQuery += "C8_IDENT, "
cQuery += "C8_ITEMGRD, "
cQuery += "C8_NUMPRO, "
cQuery += "C8_QUANT, "
cQuery += "C8_UM, "
cQuery += "C8_DATPRF, "
cQuery += "C8_FILENT, "
cQuery += "C8_NUMPED, "
cQuery += "C8_NUMCON, "
cQuery += "C8_FORNECE, "
cQuery += "C8_LOJA, "
cQuery += "C8_ITEM, "
cQuery += "C8_NUM, "
cQuery += "C8_COND, "
cQuery += "C8_FORNOME, "
cQuery += "C8_TPFRETE, "
cQuery += "C8_PRAZO, "
cQuery += "C8_ITEMSC "
cQuery += "FROM " + RetSQLName("SC8") + " "
cQuery += "WHERE D_E_L_E_T_ = ' ' AND "
cQuery += "C8_FILIAL = '" + xFilial("SC8") + "' AND "
cQuery += "C8_NUM = '" + cNum + "' "
cQuery += "ORDER BY C8_PRODUTO, C8_NUMPRO, C8_FORNECE, C8_LOJA"

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SC8MAPA",.F.,.T.)

//Quantidade de páginas
nPg := Int(nNumPro / 2)
If Mod(nNumPro,2) > 0
	nPg++
EndIf

aDadosSC8 := FWSX3Util():GetListFieldsStruct("SC8",.F.)
For nX := 1 To Len(aDadosSC8)
	nPosRef1 := At("MAFISREF(",Upper(GetSX3Cache(aDadosSC8[nX][1],"X3_VALID")))
	If nPosRef1 > 0 
		nPosRef1 += 10
		nPosRef2 := At(",", SubStr(GetSX3Cache(aDadosSC8[nX][1],"X3_VALID"), nPosRef1)) - 2
		AAdd(aRefImpos,{"SC8", aDadosSC8[nX][1], SubStr(GetSX3Cache(aDadosSC8[nX][1],"X3_VALID"), nPosRef1, nPosRef2)})
	EndIf
Next nX 

/*------- Estrutura do Array de aItens --------*/

//aItens[n,x]: Numero do item
//aItens[n,1]: C8_PRODUTO
//aItens[n,2]: C8_IDENT
//aItens[n,3]: C8_QUANT
//aItens[n,4]: C8_ UM
//aItens[n,5]: C8_ DATPRF
//aItens[n,6]: C8_ FILENT
//aItens[n,7]: valor do produto por proposta escolhida
//aItens[n,8]: Descrição do Produto
//aItens[n,9]: Flag finalizado
//aItens[n,10]: Fornecedor
//aItens[n,11]: Loja
//aItens[n,12]: Item
//aItens[n,13]: Numero da proposta
//aItens[n,14]: Item da solicitacao

/*------- Estrutura do Array de aPropostas --------*/

//CABEÇALHO//
//aPropostas[n]			: número da página
//aPropostas[n,p]			: posição do pedido na página (1,2)
//aPropostas[n,p,1,x]	: Dados do cabeçalho da proposta 
//aPropostas[n,p,1,1 ]	: Cod Fornecedor 
//aPropostas[n,p,1,2 ]	: Loja 
//aPropostas[n,p,1,3 ]	: Nome 
//aPropostas[n,p,1,4 ]	: Proposta 
//aPropostas[n,p,1,5 ]	: Cond pagto 
//aPropostas[n,p,1,6 ]	: Frete 
//aPropostas[n,p,1,7 ]	: Valor total (soma de nCusto dos itens)
//ITENS DA PROPOSTA// 
//aPropostas[n,p,2,x]	: Itens da proposta 
//aPropostas[n,p,2,x,1]	: Flag vencendor 
//aPropostas[n,p,2,x,2]	: Item
//aPropostas[n,p,2,x,3]	: Cod produto
//aPropostas[n,p,2,x,4]	: Valor total (nCusto)
//aPropostas[n,p,2,x,5]	: Data de entrega 
//aPropostas[n,p,2,x,6]	: Observações
//aPropostas[n,p,2,x,7]	: Filial Entrega 
//aPropostas[n,p,2,x,8]	: Flag finalizado 
//aPropostas[n,p,2,x,9]	: Recno SC8 

/*------- -------------------------------------- --------*/
//Adiciona Array com quantidade de páginas, propostas e cabeçalho e itens de proposta pra cada
For nX := 1 To nPg	
	aAdd(aPropostas,{{{},{}},{{},{}}})
Next nX

// Variaveis de controle da pagina e proposta na tela.
nPag    := 1
nProp   := 1
nUltPag := nPag
nUltPro := nProp

//Array de Itens na grid de Produtos
While SC8MAPA->(!EOF())
	
	//Quebra do While de Propostas
	cQuebra := SC8MAPA->(C8_PRODUTO)
	
	While !SC8MAPA->(EOF()) .And. SC8MAPA->(C8_PRODUTO) == cQuebra
		
		SC8->(DbGoTo(SC8MAPA->SC8REC))
		
		cProduto := SC8MAPA->C8_PRODUTO
		
		If SC8->C8_GRADE == 'S'
			MatGrdPrRf(@cProduto, .T.)
			
			cDesc := MaGetDescGrd(cProduto) //Recupera nome do produto
				
		Else
			
			cDesc := Posicione("SB1", 1, xFilial("SB1")+cProduto, "B1_DESC")
			
		EndIf
		
		nPosPro := AScan(aItens, {|i| i[1] == SC8MAPA->C8_PRODUTO })
		
		If nPosPro == 0
			
			AAdd(aItens, {cProduto, SC8MAPA->C8_IDENT, SC8MAPA->C8_QUANT, SC8MAPA->C8_UM, SToD(SC8MAPA->C8_DATPRF), SC8MAPA->C8_FILENT, 0, cDesc, !Empty(SC8MAPA->C8_NUMPED), SC8MAPA->C8_FORNECE, SC8MAPA->C8_LOJA, SC8MAPA->C8_ITEM, SC8MAPA->C8_NUMPRO, SC8MAPA->C8_ITEMSC })
			
		Else
			
			If aItens[nPosPro][10] == SC8MAPA->C8_FORNECE .And. aItens[nPosPro][11] == SC8MAPA->C8_LOJA .And. aItens[nPosPro][13] == SC8MAPA->C8_NUMPRO
				
				AAdd(aItens, {cProduto, SC8MAPA->C8_IDENT, SC8MAPA->C8_QUANT, SC8MAPA->C8_UM, SToD(SC8MAPA->C8_DATPRF), SC8MAPA->C8_FILENT, 0, cDesc, !Empty(SC8MAPA->C8_NUMPED), SC8MAPA->C8_FORNECE, SC8MAPA->C8_LOJA, SC8MAPA->C8_ITEM, SC8MAPA->C8_NUMPRO, SC8MAPA->C8_ITEMSC })
				
			EndIf
			
		EndIf
		
		// Controle de paginas para o caso de produtos cotados somente para alguns fornecedores dentro da mesma cotacao.
		nArmPg := AScan(aPags, {|f| f[1] == SC8MAPA->C8_FORNECE .And. f[2] == SC8MAPA->C8_LOJA .And. f[5] == SC8MAPA->C8_NUMPRO})
		
		If nArmPg == 0
			
			nPag  := nUltPag
			nProp := nUltPro
			
			If !(nPag == 1 .And. Len(aPags) == 0)
				
				If nProp == 1
					
					nProp := 2
					
				Else
					
					nPag++
					
					nProp := 1
					
				EndIf
				
			EndIf
			
			AAdd(aPags, {SC8MAPA->C8_FORNECE, SC8MAPA->C8_LOJA, nPag, nProp, SC8MAPA->C8_NUMPRO})
			
			nUltPag := nPag
			nUltPro := nProp
			
		Else
			
			nPag  := aPags[nArmPg][3] 
			nProp := aPags[nArmPg][4]
			
		EndIf
		
		//Adiciona posição no Array na primeira passagem
		If Empty(SC8MAPA->C8_ITEMGRD) .Or. SC8MAPA->C8_ITEMGRD == StrZero(1, Len(SC8MAPA->C8_ITEMGRD))
			
			AAdd(aPropostas[nPag, nProp, 2], {})
			
		EndIf		
		
		//Tratamento para Preenche Array de aPropostas
		If SC8->(DbSeek(xFilial("SC8")+cNum+SC8MAPA->(C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO+C8_ITEMGRD)))
			
			//Inicia o Valor
			lWin := .F.
			lFim := .F.
			
			//Verifica se tem numero de pedido e marca como vencedor
			If !Empty(SC8->C8_NUMPED) .Or. !Empty(SC8->C8_NUMCON)
				
				//Marca como Finalizado
				lFim := .T.
				
				//Marca como Vencedor/Perdedor				
				If SC8->C8_NUMPED # Replicate('X', Len(SC8->C8_NUMPED)) .Or.;
					(SC8->C8_NUMCON # Replicate('X', Len(SC8->C8_NUMCON)) .And. !Empty(SC8->C8_NUMCON))
					
					lWin := .T.
					
				Else
					
					lWin := .F.
										
				EndIf
				
			EndIf
			
			//Calcula o Custo para o valor total do produto
			MaFisIni(SC8->C8_FORNECE, SC8->C8_LOJA, "F", "N", "R")
			MaFisIniLoad(1)
			
			For nY := 1 To Len(aRefImpos)
				
				MaFisLoad(aRefImpos[nY, 3], SC8->(FieldGet(FieldPos(aRefImpos[nY, 2]))), 1)
				
			Next nY
			
			MaFisEndLoad(1)
			
			nCusto := Ma160Custo("SC8",1)
			
			MaFisEnd()
			
			// Tratamento para adicionar cabeçalho somente uma vez
			If Empty(aPropostas[nPag, nProp, 1])
				
				//Recupera condição de pagamento
				cPgto := Posicione("SE4", 1, xFilial("SE4")+SC8->C8_COND, "E4_DESCRI")
				
				//Preenche Array do Cabeçalho
				aPropostas[nPag, nProp, 1] := {SC8->C8_FORNECE, SC8->C8_LOJA, SC8->C8_FORNOME, SC8->C8_NUMPRO, cPgto, SC8->C8_TPFRETE, 0}
				
			EndIf
			
			//Tratamento para Itens de Grade
			If SC8->C8_GRADE == 'S'
				
				cCodRef := SC8->C8_PRODUTO
				cFrnRef := SC8->C8_FORNECE
				cLojRef := SC8->C8_LOJA
				
				lReferencia := MatGrdPrRf(@cCodRef, .T.)
				
				//Caso exista Item de Grade, apenas soma nCusto ao produto existente na Proposta				
				If !Empty(aPropostas[nPag, nProp, 2]) .And. !Empty(aPropostas[nPag, nProp, 2, 1]) .And. &('Type("aPropostas[nPag, nProp, 2, 3]")') <> 'U' .And. (nPosRef := AScan(aPropostas[nPag, nProp, 2], {|x| x[3] == cCodRef} )) > 0
					
					aPropostas[nPag, nProp, 2, nPosRef, 4] += nCusto
					
					//Soma nCusto no Valor total do Cabeçalho
					aPropostas[nPag, nProp, 1, 7] += nCusto
					
				Else
					
					//Preenche Array dos Produtos de cada proposta
					aTail(aPropostas[nPag, nProp, 2]) := {lWin, SC8->C8_ITEM, cCodRef, nCusto, (DATE()+SC8->C8_PRAZO), SC8->C8_OBS, SC8->C8_FILENT, lFim, SC8->(Recno()), SC8->C8_IDENT, Len(aItens), SC8->C8_NUMPRO}
					
					//Soma nCusto no Valor total do Cabeçalho
					aPropostas[nPag, nProp, 1, 7] += nCusto
					
				EndIf
				
			Else
				
				//Preenche Array dos Produtos de cada proposta
				//aTail(aPropostas[nPag, nProp, 2]) := {lWin, SC8->C8_ITEM, SC8->C8_PRODUTO, nCusto, (DATE()+SC8->C8_PRAZO), SC8->C8_OBS, SC8->C8_FILENT, lFim, SC8->(Recno()), SC8->C8_IDENT, Len(aItens), SC8->C8_NUMPRO}						
				aTail(aPropostas[nPag, nProp, 2]) := {lWin, SC8->C8_ITEM, SC8->C8_PRODUTO, nCusto, (DATE()+SC8->C8_PRAZO), SC8->C8_OBS, SC8->C8_FILENT, lFim, SC8->(Recno()), SC8->C8_IDENT, Len(aItens), SC8->C8_NUMPRO,SC8->C8_PRECO} // IMAEL JUNIOR 05/06/2019
				
				//Soma nCusto no Valor total do Cabeçalho
				aPropostas[nPag, nProp, 1, 7] += nCusto
				
			EndIf
			
		ElseIf Empty(SC8MAPA->C8_ITEMGRD)
			
			//Preenche Vazio Array de aProspostas, caso não hava o produto para aquela proposta
			aTail(aPropostas[nPag, nProp, 2]) := {.F., '' , '', 0, CToD('//'), '', '', .F., 0, '', Len(aItens)}
			
		EndIf
		
		If lWin
			
			aItens[Len(aItens), 7] := aPropostas[nPag, nProp, 2, Len(aPropostas[nPag, nProp, 2]), 4]
			
		EndIf
		
		//Preenche variáveis para verificar se é uma proposta (fornecedor) diferente
		cAtuPos := SC8MAPA->(C8_FORNECE+C8_LOJA+C8_NUMPRO)
		
		//Skip para a próxima linha da busca
		SC8MAPA->(DbSkip())
		
		//Atualiza a posição do Array, caso não seja o mesmo item de Grade		
		/*If (SC8MAPA->(C8_FORNECE+C8_LOJA+C8_NUMPRO)) # cAtuPos
			
			If nProp == 1
				
				nProp := 2
				
			Else
				
				nPag++
				
				nProp := 1
				
			EndIf
			
		EndIf*/
		
	EndDo
		
EndDo

// Tratamento para incluir linhas em branco no array aProposta, pois podemos ter uma proposta com mais produtos do que a outra.
For nP := 1 To Len(aPropostas)
	
	For nR := 1 To Len(aPropostas[nP])
		
		If Len(aPropostas[nP][nR][2]) < Len(aItens)
			
			nDif := Len(aItens) - Len(aPropostas[nP][nR][2]) // Quantos itens faltam para igualar as linhas entre as propostas.
			
			For nI := 1 To nDif
				
				// Adiciona posicoes faltantes para igualar as propostas, caso necessario.
				AAdd(aPropostas[nP, nR, 2], {})
				
				aTail(aPropostas[nP, nR, 2]) := {.F., '' , '', 0, CToD('//'), '', '', .F., 0, ''}
				
			Next nI
			
			For nI := 1 To Len(aPropostas[nP][nR][2])
				
				If aPropostas[nP, nR, 2, nI, 9] > 0
					
					// Aqui verifico qual a posicao correta do item com proposta no array de itens vazios (sem proposta).
					SC8->(DbGoTo(aPropostas[nP, nR, 2, nI, 9])) // Item com proposta.
					
					nPosId := AScan(aItens, {|i| i[2] == SC8->C8_IDENT})
					
					If nPosId # nI
						
						// Posiciona o item na ordem correta dentro do array de propostas.
						aPropostas[nP, nR, 2, nPosId] := aPropostas[nP, nR, 2, nI] 
						
						// Como o item estava na posição errada, limpo as colunas do array.
						aPropostas[nP, nR, 2, nI] := {.F., '' , '', 0, CToD('//'), '', '', .F., 0, ''}
						
					EndIf
					
				EndIf
				
			Next nI
			
		EndIf
		
	Next nR
	
Next nP

SC8MAPA->(DbCloseArea())

Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} U_ANewGerDoc
Função responsavel por gerar pedidos utilizando a função MaAvalCot
@param aItens Array de Itens da cotação
@param aPropostas Array de propostas da cotação
@author Leonardo Quintania
@since 29/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
User Function ANewGerDoc(aItens,aPropostas,nTipDoc)
Local cAliasSC8	:= 'SC8'
Local cProduto	:= ''
Local cVencedor	:= ''
Local cSeek		:= ''
Local cNumCot		:= SC8->C8_NUM

Local nEvento 	:= 4
Local nSaveSX8  	:= GetSX8Len()
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 0
Local nRet			:= 0
Local nItem		:= 0
Local nIProp		:= 0
Local nWin			:= 0
Local nIWin		:= 0

Local aAux			:= U_ANewSemPag(aPropostas) //Retira o array de paginas deixando as propostas sequenciais
Local aHeadSCE	:= {}
Local aSC8			:= {}
Local aWinProp	:= {}
Local aButtons	:= {}
Local aArea		
Local aDadosSCE 	:= {}

Local lRet			:= .T.
Local lExit		:= .F.
Local lClicB		:= A131VerInt()
Private cCadastro	:= STR0052//'Cadastro de Fornecedores'

aDadosSCE := FWSX3Util():GetListFieldsStruct("SCE",.F.)
For nX := 1 To Len(aDadosSCE)
	If ( X3Uso(GetSX3Cache(aDadosSCE[nX][1],"X3_USADO")) .And. cNivel >= GetSX3Cache(aDadosSCE[nX][1],"X3_NIVEL") ) .Or. AllTrim(aDadosSCE[nX][1]) == "CE_NUMPRO"
		Aadd(aHeadSCE,{ GetSX3Cache(aDadosSCE[nX][1],"X3_TITULO"), aDadosSCE[nX][1], X3Picture(aDadosSCE[nX][1]),aDadosSCE[nX][3],aDadosSCE[nX][4],GetSX3Cache(aDadosSCE[nX][1],"X3_VALID"),GetSX3Cache(aDadosSCE[nX][1],"X3_USADO"), aDadosSCE[nX][2],"",GetSX3Cache(aDadosSCE[nX][1],"X3_CONTEXT")})
	EndIf 
Next nX 

//Realiza preenchimento no array aSC8 para utilização na função MaAvalCOT.

For nX:= 1 To Len(aItens)
	
	If !aItens[nX,9]
		AADD(aSC8,{} 		)
		AADD(aWinProp,{}	)
		
		nItem 	:= Len(aSC8)
		nWin 	:= Len(aWinProp)
		
		For nY:= 1 To Len(aAux)	 //Array aPropostas desconsiderando paginas
		
			For nZ:= 1 To Len(aAux[nY,2]) //Array de Itens das aPropostas
			
				If aItens[nX,2] == aAux[nY,2,nZ,10] .And. aItens[nX,13] ==  aAux[nY,2,nZ,12] //Verifico se existe proposta para o item posicionado
				
					SC8->(dbGoTo(aAux[nY,2,nZ,9])) //Posiciono no SC8 para verificar se o fornecedor está preenchido
					
					If aAux[nY,2,nZ,1] //Verifico se foi marcado o item como vencedor
						cVencedor:= SC8->(C8_FORNECE+C8_LOJA)
						If Empty(cVencedor)//Se estiver em branco esse fornecedor é um participante e deve ser cadastrado como fornecedor
							aButtons:= {STR0053,STR0054,STR0055,STR0056} //STR0053,STR0054,STR0055,STR0056//'Sim'//'Não'//'Sim p/ Todos'//'Não p/ Todos'
							If nRet < 3 //'Sim','Não','Sim p/ Todos'
								nRet:= Aviso(STR0057,STR0058+ aAux[nY,2,nZ,2]	+' - '+ AllTrim(aAux[nY,2,nZ,3]) +' - '+AllTrim(aItens[nX,8])+STR0059+AllTrim(aAux[nY,1,3])+STR0060,aButtons,2)//'Atenção'//'O item '//' teve como ganhador um participante não cadastrado como fornecedor ('//'). Deseja cadastrá-lo agora? Em caso negativo, este item da cotação não será finalizado.'
							EndIf
							
							If nRet==1 .Or. nRet==3 //'Sim','Sim p/ Todos'
								lRet := (A020WebbIc({ {"A2_NREDUZ",SC8->C8_FORNOME},{"A2_EMAIL",SC8->C8_FORMAIL} })) == 1
								If lRet
									ANewAtuCot(SC8->C8_FORNOME,SA2->A2_COD,SA2->A2_LOJA)
									cVencedor:= SA2->(A2_COD+A2_LOJA)
								EndIf
								
							Else					
								lRet:= .F.
							EndIf
						EndIf
					
					EndIf
					
					If lRet
						
						cRefer := SC8->C8_PRODUTO
						lReferencia := MatGrdPrRf(@cRefer,.T.) .And. AllTrim(cRefer) == AllTrim(aItens[nX,1]) 
						
						If lReferencia 
							SC8->(dbSetOrder(4))//C8_FILIAL+C8_NUM+C8_IDENT+C8_PRODUTO
							cSeek := xFilial('SC8')+SC8->(C8_NUM+C8_IDENT) 
							SC8->(dbSeek(cSeek)) 
						EndIf
						
						While !lReferencia .Or. (!SC8->(EOF()) .And. SC8->(C8_FILIAL+C8_NUM+C8_IDENT) == cSeek) 
							AADD(aSC8[nItem],{})
							nIProp := Len(aSC8[nItem])
								
							AADD(aSC8[nItem,nIProp],{'C8_ITEM'		, SC8->C8_ITEM		} )
							AADD(aSC8[nItem,nIProp],{'C8_NUMPRO'	, SC8->C8_NUMPRO		} )
							AADD(aSC8[nItem,nIProp],{'C8_PRODUTO'	, SC8->C8_PRODUTO		} )
							AADD(aSC8[nItem,nIProp],{'C8_COND'		, SC8->C8_COND		} )
							AADD(aSC8[nItem,nIProp],{'C8_FORNECE'	, SC8->C8_FORNECE		} )
							AADD(aSC8[nItem,nIProp],{'C8_LOJA'		, SC8->C8_LOJA		} )
							AADD(aSC8[nItem,nIProp],{'C8_NUM'		, SC8->C8_NUM			} )
							AADD(aSC8[nItem,nIProp],{'C8_ITEMGRD'	, SC8->C8_ITEMGRD		} )
							AADD(aSC8[nItem,nIProp],{'C8_NUMSC'	, SC8->C8_NUMSC		} )
							AADD(aSC8[nItem,nIProp],{'C8_ITEMSC'	, SC8->C8_ITEMSC		} )	
							AADD(aSC8[nItem,nIProp],{'C8_FILENT'	, SC8->C8_FILENT		} )				
							AADD(aSC8[nItem,nIProp],{'C8_OBS'		, aAux[nY, 2, nZ, 6]	} )
							AADD(aSC8[nItem,nIProp],{'SC8RECNO'	, SC8->(Recno())		} )		
							If !aAux[nY,2,nZ,8] //Flag de Finalizado
								AADD(aWinProp[nWin],{} )
								nIWin := Len(aSC8[nWin])
								
								AADD(aWinProp[nWin,nIWin] , SC8->C8_NUMPRO			) //CE_NUMPRO
								AADD(aWinProp[nWin,nIWin] , SC8->C8_FORNECE			) //CE_FORNECE
								AADD(aWinProp[nWin,nIWin] , SC8->C8_LOJA	 			) //CE_LOJA
								If cVencedor == SC8->(C8_FORNECE+C8_LOJA) .and. aAux[nY,2,nZ,1] 			//Verifica se é o fornecedor vencedor posicionado
									AADD(aWinProp[nWin,nIWin] , SC8->C8_QUANT	 		) //CE_QUANT
									cVencedor:= ''
									aAux[nY,2,nZ,1]:=.F.
								Else
									AADD(aWinProp[nWin,nIWin] , 0				 		) //CE_QUANT com quantidade zero para marcar XXXXXXXX
									cVencedor:= ''
								EndIf
								AADD(aWinProp[nWin,nIWin] , SC8->C8_MOTIVO 			) //CE_MOTIVO
								AADD(aWinProp[nWin,nIWin] , (Date()+SC8->C8_PRAZO) 	) //CE_ENTREGA
								AADD(aWinProp[nWin,nIWin] , 0				 			) //CE_REGIST
								AADD(aWinProp[nWin,nIWin] , SC8->C8_ITEMGRD			) //CE_ITEMGRD
								AADD(aWinProp[nWin,nIWin] , SC8->C8_ITEM				) //CE_ITEMCOT
								AADD(aWinProp[nWin,nIWin] , SC8->C8_NUM				) //CE_NUMCOT
								AADD(aWinProp[nWin,nIWin] , 'SC8'						) //CE_ALI_WT
								AADD(aWinProp[nWin,nIWin] , SC8->(Recno())			) //CE_REC_WT
							EndIf
							
							If !lReferencia
								Exit
							Else
								SC8->(dbSkip())
								lExit:= .T.
							EndIf							
						End	
					
					Else
						If nRet > 2 //'Sim p/ Todos','Não p/ Todos'
							Aviso(STR0061,STR0062+AllTrim(aAux[nY,1,3])+STR0063+ aAux[nY,2,nZ,2]	+' - '+ AllTrim(aAux[nY,2,nZ,3]) +' - '+AllTrim(aItens[nX,8])+STR0064,{STR0065})//'Atenção'//'O cadastro do participante '//' foi cancelado e a cotação do item '//' não será finalizada.'//'Ok'
						EndIf
						lExit:= .T.
					EndIf
					
				EndIf
				If lExit
					Exit
				EndIf
			Next nZ
			If lExit
				Exit
			EndIf	
		Next nY
		
	EndIf
	
Next nX

aArea := GetArea()
Begin Transaction

	If nTipDoc == 1
		//Pedido de Compra
		If lRet .And. Len(aSC8) > 0 .And. ( MaAvalCOT(cAliasSC8, nEvento, aSC8, aHeadSCE, aWinProp, .F., Nil, {|| .T.}) ) //Executa função que gera pedidos de compra.
			EvalTrigger()
			While ( GetSX8Len() > nSaveSX8 )
				ConfirmSx8()		
			EndDo
		Else
			While ( GetSX8Len() > nSaveSX8 )
				RollBackSx8()
			EndDo
		EndIf          		
	Else
		If lRet .And. U_ANewCntr(aWinProp)
			While ( GetSX8Len() > nSaveSX8 )
					ConfirmSx8()		
			EndDo
		Else
			While ( GetSX8Len() > nSaveSX8 )
				RollBackSx8()
			EndDo
		EndIf
	EndIf 	

	SC8->(dbSetOrder(4))
	SC8->(dbSeek(xFilial("SC8")+cNumCot))
	While !SC8->(Eof()) .AND. SC8->C8_NUM == cNumCot
		RecLock("SC8",.F.)
			SC8->C8_TPDOC := CvalToChar(nTipDoc)
		MsUnlock()
		SC8->(dbSkip())
	EndDo
End Transaction 

If lClicB
	A311RegCot(cNumCot,2)
Endif
RestArea( aArea )
Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} U_ANewSemPag
Função responsavel por desconsiderar numero de pagina no array de aProposta
@param aPropostas Array de propostas da cotação
@author Leonardo Quintania
@since 30/10/2013
@version P11.90
*/
//-------------------------------------------------------------------

User Function ANewSemPag(aPropostas)
Local aAux	:= {}
Local nX	:=	0
Local nY	:= 	0

For nX:= 1 To Len(aPropostas)

	For nY:= 1 To Len(aPropostas[nX])

		aAdd(aAux, aPropostas[nX,nY] )

	Next nY

Next nX

Return aAux

//-------------------------------------------------------------------
/*{Protheus.doc} U_ANewHisForn
Função responsavel por trazer o histórico do fornecedor
@author antenor.silva
@since 30/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
User Function ANewHisForn(cFornece,cLoja)
Local aArea	:= GetArea()

SA2->(dbSetOrder(1))
If SA2->(dbSeek(xFilial('SA2')+cFornece+cLoja))

	If Pergunte("FIC030",.T.)
		Finc030("Fc030Con")
	EndIf

	Pergunte("MTA160",.F.)

EndIf

RestArea(aArea)

Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} 
Função responsavel por trazer o histórico do produto
@author antenor.silva
@since 30/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
User Function ANewHisPro(cProduto)
Local aArea	:=	GetArea()

MaFisSave()
MaFisEnd()

If !AtIsRotina("MACOMVIEW")
	If !Empty(cProduto)
		MaComView(cProduto)
	EndIf
EndIf

MaFisRestore()

RestArea(aArea)

Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} ANewDesMark
Desmarcar as propostas na seleção
@param nPag Pagina da proposta Atual para desconsiderar da seleção
@param nProp Numero da proposta Atual para desconsiderar da seleção
@param nLinha Linha da proposta Atual 
@param aPropostas Array de Propostas disponivel
@author Leonardo Quintania
@since 28/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
Static Function ANewDesMark(nPag,nProp,nLinha,aPropostas,aItens,oBrowse1,oBrowse2,oBrowse3,lObs)
Local nX := 0
Local nY := 0
Local nZ := 0
Local aAux	:= {}

If !Empty(aPropostas[nPag,nProp,2,nLinha,2])
	If aPropostas[nPag, nProp, 2, nLinha, 4] > 0
		If !aPropostas[nPag,nProp,2,nLinha,8] //Verifica se na linha selecionada existe algum flag de finalizado.
			aPropostas[nPag,nProp,2,nLinha,1]:= !aPropostas[nPag,nProp,2,nLinha,1]
			If lObs
				
				aPropostas[nPag,nProp,2,nLinha,6]:= AllTrim(aPropostas[nPag,nProp,2,nLinha,6]) + Space(1) + "ENCERRADO AUTOMATICAMENTE" // ENCERRADO AUTOMATICAMENTE
				
			EndIf
			If aPropostas[nPag,nProp,2,nLinha,1]
				aItens[nLinha,7] := aItens[nLinha,7] + aPropostas[nPag,nProp,2,nLinha,4]
			Else
				aItens[nLinha,7] := aItens[nLinha,7] - aPropostas[nPag,nProp,2,nLinha,4]
			EndIf
			For nX :=1 To Len(aPropostas)
				If aPropostas[nX,1,2,nLinha,1] .Or. (!Empty(aPropostas[nX,2,2]) .And. aPropostas[nX,2,2,nLinha,1])
					If nX # nPag .Or. nProp == 2
						
						If aPropostas[nX,1,2,nLinha,1]
							aPropostas[nX,1,2,nLinha,1] := .F.
							aItens[nLinha,7] := aItens[nLinha,7] - aPropostas[nX,1,2,nLinha,4]
						EndIf
						
					EndIf
					If (nX # nPag .Or. nProp == 1) .And. !Empty(aPropostas[nX,2,2])
						
						If aPropostas[nX,2,2,nLinha,1]
							aPropostas[nX,2,2,nLinha,1] := .F.
							aItens[nLinha,7] := aItens[nLinha,7] - aPropostas[nX,2,2,nLinha,4]
						EndIf
						
					EndIf
				EndIf
			Next nX
		
			If SuperGetMV("MV_PCOINTE",.F.,"2")=="1"
				SC8->(dbGoTo(aPropostas[nPag,nProp,2,nLinha,9]))
				SC1->(DbSetOrder(1))
				SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUMSC+C8_ITEMSC)))
				If !ANewPcoVld(!aPropostas[nPag,nProp,2,nLinha,1])
					PcoFreeBlq('000051')
					PcoFreeBlq('000052')
					
					aPropostas[nPag,nProp,2,nLinha,1] := .F.
					
					If aPropostas[nPag,nProp,2,nLinha,1]
						aItens[nLinha,7] := aItens[nLinha,7] + aPropostas[nPag,nProp,2,nLinha,4]
					Else
						aItens[nLinha,7] := aItens[nLinha,7] - aPropostas[nPag,nProp,2,nLinha,4]
					EndIf
					For nX :=1 To Len(aPropostas)
						If aPropostas[nX,1,2,nLinha,1] .Or. (!Empty(aPropostas[nX,2,2]) .And. aPropostas[nX,2,2,nLinha,1])
							If nX # nPag .Or. nProp == 2
								If aPropostas[nX,1,2,nLinha,1]
									aPropostas[nX,1,2,nLinha,1] := .F.
									aItens[nLinha,7] := aItens[nLinha,7] - aPropostas[nX,1,2,nLinha,4]
								EndIf
							EndIf
							If (nX # nPag .Or. nProp == 1) .And. !Empty(aPropostas[nX,2,2])
								If aPropostas[nX,2,2,nLinha,1]
									aPropostas[nX,2,2,nLinha,1] := .F.
									aItens[nLinha,7] := aItens[nLinha,7] - aPropostas[nX,2,2,nLinha,4]
								EndIf
							EndIf
						EndIf
					Next nX
			
				EndIf  
			EndIf
			
		EndIf
				
		oBrowse1:Refresh(.T.)
		oBrowse2:Refresh(.T.)
		oBrowse3:Refresh(.T.)

	Endif
EndIf

Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} ANewMarkAll
Efetua a marcação de todos os itens da grid da proposta atual

@author Leonardo Quintania
@since 28/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
Static Function ANewMarkAll(nPag,nProp,aPropostas,aItens,oBrowse1,oBrowse2,oBrowse3)
Local nX := 0
Local lDesmark := .F.

For nX :=1 To Len(aPropostas[nPag,nProp,2])
	If !aPropostas[nPag,nProp,2,nX,1]
		lDesmark := .T.
	EndIf
Next nX

For nX :=1 To Len(aPropostas[nPag,nProp,2])	
	If !aPropostas[nPag,nProp,2,nX,8] .And. !Empty(aPropostas[nPag,nProp,2,nX,2])
		If lDesmark
			If !aPropostas[nPag,nProp,2,nX,1]
				ANewDesMark(nPag,nProp,nX,@aPropostas,@aItens,oBrowse1,oBrowse2,oBrowse3,.F.)
			Endif
		Else
			If aPropostas[nPag,nProp,2,nX,1]
				ANewDesMark(nPag,nProp,nX,@aPropostas,@aItens,oBrowse1,oBrowse2,oBrowse3,.F.)
			Endif
		Endif
	EndIf
Next nX


oBrowse1:Refresh(.T.)
oBrowse2:Refresh(.T.)
oBrowse3:Refresh(.T.)
	
Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} ANewCalTot
Calcula valor total da analise da cotação

@author Leonardo Quintania
@since 28/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
Static Function ANewCalTot(aItens)
Local nX 		:= 1
Local nTotal	:= 0

For nX :=1 To Len(aItens)
	nTotal+= aItens[nX,7]

Next nX


Return nTotal

//-------------------------------------------------------------------
/*{Protheus.doc} U_ANewMovPag
Altera a pagina de propostas da cotação
@author Antenor Silva
@since 28/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
User Function ANewMovPag(aPropostas, oBrowse2, oBrowse3, nPagina, cFor1, nProp1, cCondPag1, cTpFrete1, nVlTot1, cFor2, nProp2, cCondPag2, cTpFrete2, nVlTot2,oPanel3,oBrowse1)
Local lTam	:= 0

If (Len(aPropostas) >= nPagina) .And. (nPagina > 0) 
 
 //if !Empty(aPropostas[nPagina][1][1]) // Comentado, pois esta impedindo o avanco das paginas em alguns casos.
       lTam := !Empty(aPropostas[nPagina,2,1])

		oBrowse2:SetArray(aPropostas[nPagina,1,2])
       oBrowse2:Refresh(.T.)
              
		cFor1 		:= aPropostas[nPagina][1][1][3]
		nProp1		:= aPropostas[nPagina][1][1][4]
		cCondPag1	:= aPropostas[nPagina][1][1][5]
		cTpFrete1	:= U_ANewDscF(aPropostas[nPagina][1][1][6])
		nVlTot1	:= aPropostas[nPagina][1][1][7] 
              
       If !lTam
			//Esconde o segundo browse
	       oPanel3:lVisible := .F.
	       oBrowse3:Hide()
	       SetKey(VK_F8,{||Nil})
       Else
	       oBrowse3:Show()
	       oPanel3:lVisible := .T.
			oBrowse3:SetArray(aPropostas[nPagina,2,2])
			oBrowse3:Refresh(.T.)
			SetKey( VK_F8,{||U_ANewHisForn(aPropostas[nPagina][2][1][1],aPropostas[nPagina][2][1][2])})	
	          	
	       cFor2 		:= aPropostas[nPagina][2][1][3]
			nProp2		:= aPropostas[nPagina][2][1][4]
			cCondPag2	:= aPropostas[nPagina][2][1][5]
			cTpFrete2	:= U_ANewDscF(aPropostas[nPagina][2][1][6])
			nVlTot2	:= aPropostas[nPagina][2][1][7]    	            
       EndIf
       oBrowse1:Refresh(.T.)
 //EndIf 
       
EndIf 
Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} ANewAtuCot
Função que efetua atualização com o numero do fornecedor que foi cadastrado
@param cForNome Nome do fornecedor participante
@param cNewFor Codigo do fornecedor que foi cadastrado 
@param cNewLoj Loja do fornecedor que foi cadastrado 
@author Leonardo Quintania
@since 28/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
Static Function ANewAtuCot(cForNome,cNewFor,cNewLoj)
Local cFornece:= CriaVar("C8_FORNECE",.F.)
Local aAreaSC8 := SC8->(GetArea())

BeginSQL Alias 'SC8TMP'
		
	SELECT R_E_C_N_O_ SC8RECNO
	FROM %Table:SC8% SC8
	WHERE SC8.%NotDel% AND
	SC8.C8_FILIAL = %xFilial:SC8% AND
	SC8.C8_FORNOME = %Exp:cForNome% AND
	SC8.C8_FORNECE = %Exp:cFornece%

EndSql

//Percorrer o resultado do select
While !SC8TMP->(EOF())
	SC8->(dbGoto(SC8TMP->SC8RECNO))
	RecLock("SC8",.F.)
	SC8->C8_FORNECE	:= cNewFor
	SC8->C8_LOJA		:= cNewLoj
	SC8->(MsUnlock())

	SC8TMP->(dbSkip())	
EndDo

SC8TMP->(dbCloseArea())

RestArea(aAreaSC8)

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} U_ANewCntr()
Função para geração de Contrato a partir do Mapa de Cotação
@Param aWinProp Array com resultado das cotações para a geração do 
		contrato
@author Flavio Lopes Rasta 
@since 09/01/2014
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
User Function ANewCntr(aWinProp)
Local aArea := GetArea()
Local lRet		:= .T.
Local aDados		:= U_ANewOderna(aWinProp)
Local oModel300 	:= FWLoadModel( "CNTA300" )
Local cTpPla	:= SuperGetMV("MV_TPPLA", .T., "")
Local nGravou
Local nTpContr	:= 1	

If Len(aDados) > 0
	CNL->(dbSetOrder(1))
	If	Empty(cTpPla)
		Help("",1,"MV_TPPLA",,STR0066,4,1)	//" Parâmetro não Preenchido. É necessário preencher o parâmetro MV_TPPLA com um Tipo de Planilha válido para a geração dos contratos"
		lRet	:= .F.
	ElseIf CNL->( ! DbSeek(xFilial("CNL")+cTpPla) )
		Help("",1,STR0067,,STR0068,4,1)//"Planilha Inválida"//"É necessário preencher o parâmetro MV_TPPLA com um Tipo de Planilha válido para a geração dos contratos"
		lRet	:= .F.
	Endif
	If lRet
		If Len(aDados) > 1
		nTpContr	:= Aviso(STR0069,STR0070,{STR0071,STR0072})//"Tipo do Contrato"//"Será gerado um contrato em Conjunto(todos os fornecedores) ou Individual(um por fornecedor)?"//"Conjunto"//"Individual"
		Endif
		If nTpContr == 1
			oModel300:SetOperation(3)                                 
			oModel300:Activate()
			Begin Transaction
				nGravou  := FWExecView (STR0073 , "CNTA300" , MODEL_OPERATION_INSERT ,, {||.T.},,,,,,, U_ANewMdlCot(oModel300,aDados) )//'Incluir'
				U_ANewAtSC8(aDados,CN9->CN9_NUMERO)
				If nGravou == 1
					lRet := .F.
					DisarmTransaction()
				Endif
			End Transaction
		Else
			nGravou  := U_ANewMdlFor(aDados)
		Endif
	EndIf
Else
	lRet:= .F.
Endif		
RestArea( aArea )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} U_ANewOderna()
Função para geração de Contrato a partir do Mapa de Cotação
@Param aWinProp Array com resultado das cotações para a geração do 
		contrato
@author Flavio Lopes Rasta 
@since 09/01/2014
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
User Function ANewOderna(aWinProp)
Local aWinners	:=	{}
Local aFornece	:=	{}
Local aDados		:=	{}
Local cFornCor	 
Local cLojaCor
Local nX,nY

//Busca os Fornecedores vencedores da cotação
For nX:=1 To Len(aWinProp)
	For nY:=1 To Len(aWinProp[nX])
		If aWinProp[nX][nY][4] > 0
			AADD(aWinners,aWinProp[nX][nY])
		Endif
	Next	
Next
If Len(aWinners) > 0
	// Agrupa vencedores por fornecedor 
	For nX:=1 To Len(aWinners)
		cFornCor := aWinners[nX][2]
		cLojaCor := aWinners[nX][3]
		If aScan(aFornece,{|x| x[1]+x[2] == cFornCor+cLojaCor }) == 0
			Aadd(aDados,cFornCor)
			Aadd(aDados,cLojaCor)
			For nY:=1 To Len(aWinners)
				If cFornCor == aWinners[nY][2] .And. cLojaCor == aWinners[nY][3]
					Aadd(aDados,aWinners[nY])
				Endif 
			Next
			Aadd(aFornece,aDados)
			aDados := {}
		Endif
	Next
Endif
	
Return aFornece

//-------------------------------------------------------------------
/*/{Protheus.doc} U_ANewMdlCot()
Função para geração de Contrato a partir do Mapa de Cotação
@Param aWinProp Array com resultado das cotações para a geração do 
		contrato
@author Flavio Lopes Rasta 
@since 09/01/2014
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
User Function ANewMdlCot(oModel300,aDados)
Local aArea := GetArea()
Local nX,nY
Local oCN9Master	:= oModel300:GetModel('CN9MASTER')
Local oCNADetail	:= oModel300:GetModel('CNADETAIL')
Local oCNBDetail	:= oModel300:GetModel('CNBDETAIL')
Local oCNCDetail	:= oModel300:GetModel('CNCDETAIL')
Local oCNZDetail	:= oModel300:GetModel('CNZDETAIL')
Local cItem		:= Replicate("0", (TamSx3('CNB_ITEM')[1]))
Local cItPla		:= Replicate("0",(TamSx3('CNA_NUMERO')[1]))
Local cTpPla	:= SuperGetMV("MV_TPPLA", .T., "")
Local cItemRat
Local lRateio		:= .F.
Local cSeekCNZ


// Popula o modelo do contrato
oCN9Master:SetValue('CN9_ESPCTR',"1")//Contrato de Compra
oCN9Master:SetValue('CN9_DTINIC',dDataBase)
oCN9Master:SetValue('CN9_UNVIGE',"4")//Ideterminada
oCN9Master:SetValue('CN9_NUMCOT',SC8->C8_NUM)
cItPla	:= soma1(cItPla)

For nX:=1 To Len(aDados)
	cItem		:= Replicate("0", (TamSx3('CNB_ITEM')[1]))
	cItem	:= soma1(cItem)
	If nX > 1
		oCNCDetail:AddLine()
		oCNADetail:AddLine()
		cItPla	:= soma1(cItPla)
	Endif
	oCNCDetail:SetValue('CNC_CODIGO',aDados[nX][1])
	oCNCDetail:SetValue('CNC_LOJA',aDados[nX][2])
	oCNADetail:SetValue('CNA_FORNEC',aDados[nX][1])
	oCNADetail:SetValue('CNA_LJFORN',aDados[nX][2])
	oCNADetail:SetValue('CNA_TIPPLA',cTpPla)
	oCNADetail:SetValue('CNA_NUMERO',cItPla)			
	//oCNADetail:SetValue('CNA_DTINI',)
	For nY:=3 To Len(aDados[nX])
		If nY > 3
			oCNBDetail:AddLine()
			cItem	:= soma1(cItem)
		Endif		
	
		//oCNBDetail:SetValue('CNB_ITEM',cItem)
		SC8->(dbSetOrder(1))
		SC8->(DbSeek(xFilial('SC8')+aDados[nX][nY][10]+aDados[nX][1]+aDados[nX][2]+aDados[nX][nY][9]))
		
		oCNBDetail:SetValue('CNB_ITEM',cItem)
		oCNBDetail:SetValue('CNB_PRODUT',SC8->C8_PRODUTO)			
		oCNBDetail:SetValue('CNB_QUANT',aDados[nX][nY][4])
		oCNBDetail:SetValue('CNB_NUMSC',SC8->C8_NUMSC)
		oCNBDetail:SetValue('CNB_ITEMSC',SC8->C8_ITEMSC)
		oCNBDetail:SetValue('CNB_VLUNIT',SC8->C8_PRECO)
		oCNBDetail:SetValue('CNB_VLTOTR',SC8->C8_TOTAL)
		oCNBDetail:SetValue('CNB_IDENT',SC8->C8_IDENT)
		
		//Verifica se possui rateio
		SCX->(DbSetOrder(1))
		lRateio := SCX->(dbSeek(cSeekCNZ := xFilial("SCX")+SC8->(C8_NUMSC+C8_ITEMSC)))
		If lRateio
			cItemRat := Replicate("0", (TamSx3('CNZ_ITEM')[1]))
			While SCX->(!Eof()) .And. SCX->(CX_FILIAL+CX_SOLICIT+CX_ITEMSOL) == cSeekCNZ 
				If cItemRat <> Replicate("0", (TamSx3('CNZ_ITEM')[1]))
					oCNZDetail:AddLine()		
				EndIf
				cItemRat := Soma1(cItemRat)
						
				oCNZDetail:SetValue('CNZ_ITEM',cItemRat)
				oCNZDetail:SetValue('CNZ_PERC',SCX->CX_PERC)
				oCNZDetail:SetValue('CNZ_CC',SCX->CX_CC)		
				oCNZDetail:SetValue('CNZ_CONTA',SCX->CX_CONTA)
				oCNZDetail:SetValue('CNZ_ITEMCT',SCX->CX_ITEMCTA)
				oCNZDetail:SetValue('CNZ_CLVL',SCX->CX_CLVL)
				SCX->(dbSkip())			
			End			
		Else
			SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUMSC+C8_ITEMSC)))
			oCNBDetail:SetValue('CNB_CC',SC1->C1_CC)
			oCNBDetail:SetValue('CNB_CLVL',SC1->C1_CLVL)		
			oCNBDetail:SetValue('CNB_CONTA',SC1->C1_CONTA)
			oCNBDetail:SetValue('CNB_ITEMCT',SC1->C1_ITEMCTA)																											
		EndIf					
	Next
Next
oCNADetail:GoLine(1)
oCNBDetail:GoLine(1) 
oCNCDetail:GoLine(1) 
oCNZDetail:GoLine(1) 

CNTA300BlMd(oModel300:GetModel('CNBDETAIL'),.T.)
CNTA300BlMd(oModel300:GetModel('CNZDETAIL'),.T.)
CNTA300BlMd(oModel300:GetModel('CNCDETAIL'),.T.)
CNTA300BlMd(oModel300:GetModel('CNADETAIL'),.T.,.T.)

RestArea( aArea )
Return oModel300

//-------------------------------------------------------------------
/*/{Protheus.doc} U_ANewMdlFor()
Função para geração de Contrato a partir do Mapa de Cotação
@Param aWinProp Array com resultado das cotações para a geração do 
		contrato
@author Flavio Lopes Rasta 
@since 09/01/2014
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
User Function ANewMdlFor(aDados)
Local aForn	:= {}
Local lRet	:= .F.
Local nGravou
Local nX
Local oModel300 	

Begin Transaction

	For nX:=1 To Len(aDados)
		 
		oModel300 	:= FWLoadModel( "CNTA300" )
		oModel300:SetOperation(3)                                 
		oModel300:Activate()
		nGravou := FWExecView (STR0073 , "CNTA300" , MODEL_OPERATION_INSERT ,, {||.T.},,,,,,, U_ANewMdlCot(oModel300,{aDados[nX]}))//'Incluir'
		U_ANewAtSC8({aDados[nX]},CN9->CN9_NUMERO)
		If nGravou == 1
			lRet := .F.
			DisarmTransaction()
			Exit
		Endif
		oModel300 	:= Nil 
	Next
	
End Transaction

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} U_ANewAtSC8()
Função para atualização da cotação
após geração do contrato
@Param aWinProp Array com resultado das cotações para a geração do 
		contrato
@author Flavio Lopes Rasta 
@since 09/01/2014
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
User Function ANewAtSC8(aDados,cContrato)
Local aArea := GetArea()
Local cChavSC8
Local cNumSC8
Local cItem 
Local lRet := .F.
Local nX,nY

For nX:= 1 To Len(aDados)
	For nY:=3 To Len(aDados[nX])
		cChavSC8	:= xFilial('SC8')+aDados[nX][nY][10]+aDados[nX][1]+aDados[nX][2]+aDados[nX][nY][9] //Numero+Fornecedor+Loja+Item
		cItem		:= aDados[nX][nY][9] 
		cNumSC8	:= aDados[nX][nY][10]
		SC8->(dbSetOrder(1))
		SC8->(DbSeek(xFilial('SC8')+cNumSC8))
		//Encerra cotação
		While !SC8->(Eof()) .And. SC8->C8_NUM == cNumSC8 
			RecLock("SC8",.F.)
			If SC8->(C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM)== cChavSC8
				SC8->C8_NUMCON := cContrato
				SC8->C8_NUMPED := Replicate("X", (TamSx3('C8_NUMPED')[1]))	
			Else
				If Empty(SC8->C8_NUMCON) .And. SC8->C8_ITEM == cItem
					SC8->C8_NUMCON := Replicate("X", (TamSx3('C8_NUMCON')[1]))
					SC8->C8_NUMPED := Replicate("X", (TamSx3('C8_NUMPED')[1]))		
				Endif
			Endif
			MsUnlock()
			SC8->(DbSkip())
		EndDo
	Next
Next

RestArea( aArea )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} U_ANewDscF()
Função para descrever o frete
após geração do contrato

@author Flavio Lopes Rasta 
@since 22/07/2014
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------

User Function ANewDscF(cTpFrete)
Local cRet:=""

If cTpFrete == 'C'
	cRet := STR0075 //"CIF"
ElseIf cTpFrete == 'F'
	cRet := STR0076 //"FOB"
ElseIf cTpFrete == 'T'
	cRet := STR0077 //"Terceiros"
ElseIf cTpFrete == 'S' .OR. Empty(cTpFrete)
	cRet := STR0078 //"Sem Frete"
Endif

Return cRet

Static Function ShowBMemo(cString)
Local oEditor := nil
Local oSize 	:= nil
Local oDlMemo := nil

Local bOk     := {|| TRATAMOT(oDlMemo, oEditor, @cString) }
Local bCancel := {|| oDlMemo:End() }
	
	DEFINE MSDIALOG oDlMemo FROM 180, 180 TO 550, 700 TITLE 'MEMO' PIXEL 

	oEditor := TSimpleEditor():New(3,0,oDlMemo,263,146)
	oEditor:Load(cString)
	oEditor:lReadOnly := .F.
	
	ACTIVATE MSDIALOG oDlMemo CENTERED ON INIT EnchoiceBar(oDlMemo, bOk, bCancel)

Return .T.

/*------- Estrutura do Array aPrdXFor --------*/

//aPrdXFor[n,X]: Produto
//aPrdXFor[n,X,Y]: Fornecedor
//aPrdXFor[n,X,Y,1]: Preço
//aPrdXFor[n,X,Y,2]: Prazo
//aPrdXFor[n,X,Y,3]: Nota
//aPrdXFor[n,X,Y,4]: Nota Final (menor vence)
//aPrdXFor[n,X,Y,5]: Referência ao aProposta
//aPrdXFor[n,X,Y,5,1]: página
//aPrdXFor[n,X,Y,5,2]: Referência ao aProposta
//aPrdXFor[n,X,Y,5,3]: Referência ao aProposta

/*------- Estrutura do Array de aPrdMinMax --------*/

//aPrdXFor[n,X]: Produto
//aPrdXFor[n,X,1]: Maior Nota
//aPrdXFor[n,X,2]: Menor Nota
//aPrdXFor[n,X,3]: Qtd. Part
//aPrdXFor[n,X,4]: Média
//aPrdXFor[n,X,5]: Melhor Fator


//-------------------------------------------------------------------
/*/{Protheus.doc} U_ANewCotVen()
Sugestão da cotação vencedora

@author guilherme.pimentel
 
@since 04/11/2015
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------

User Function ANewCotVen(aItens, aPropostas,oBrowse1,oBrowse2,oBrowse3)

Local aPrdXFor	:= {}
Local aPrdMinMax	:= {}
Local aAux 		:= {}
Local aRank 		:= {}
Local aForVenc 	:= {}

Local nX := 1
Local nY := 1
Local nZ := 1
Local nJ := 1
Local nC := 1
Local nI := 0

Local nMax := 1
Local nMin := 1

Local aPosPrc := {}
Local aPosPrz := {}
Local aPosNot := {}

Local nMenPrc := 0 // Menor preco.
Local nMenPrz := 0 // Menor prazo.
Local nMaiNot := 0 // Maior nota.

Local lAchou := .F.

Local aBkpRank := {}

// -----------------------------------------------------------------------
// Montagem do array de Produtos X Propostas e de Valores Máximos e Minimos
// -----------------------------------------------------------------------

For nX := 1 To Len(aItens)
	
	aAdd(aPrdXFor, {aItens[nX,1]} )
	
	aAdd(aPrdMinMax, {aItens[nX,1]} )
	aAdd(aPrdMinMax[nX], {,,0,0,0} ) // Preço
	aAdd(aPrdMinMax[nX], {,,0,0,0} ) // Prazo
	aAdd(aPrdMinMax[nX], {,,0,0,0} ) // Nota
	
	For nY := 1 To Len(aPropostas)
		//Verificação das duas propostas
		For nJ := 1 To 2
			//Verificação de todos os itens das propostas
			For nZ := 1 To Len(aPropostas[nY][nJ][2])
				//Se encontrar proposta para aquele produto adiciona no Array
				If aPropostas[nY][nJ][2][nZ][3] == aItens[nX,1] .And. aPropostas[nY][nJ][2][nZ][11] == nX
					
					//Adiciona o Fornecedor
					aAdd(aAux,aPropostas[nY][nJ][1][1])
					aAdd(aAux,{})
					
					//Adiciona itens
					aAdd(aAux[2],aPropostas[nY][nJ][1][4]) //Proposta
					aAdd(aAux[2],aPropostas[nY][nJ][2][nZ][4]) //Preço
					aAdd(aAux[2],U_ANewDToI(aPropostas[nY][nJ][2][nZ][5])) // Prazo
					
					If SA5->(DbSeek(xFilial("SA5")+aPropostas[nY][nJ][1][1]+aPropostas[nY][nJ][1][2]+aItens[nX,1])) //Filial+Fornecedor+Loja+Produto
						aAdd(aAux[2],SA5->A5_NOTA) //Nota
					Else
						aAdd(aAux[2],0) //Nota
					EndIf
					
					aAdd(aAux[2],0) //Nota Final
					
					aAdd(aAux[2],{nY,nJ,nZ}) //Referência ao aProposta
					
					//Verificação de máximo e minimo para o Item adicionado
					U_ANewMinMax(aPropostas[nY][nJ],aPropostas[nY][nJ][2][nZ],@aPrdMinMax[nX],nZ)
					
				EndIf
			 			
			If !Empty(aAux)
				aAdd(aPrdXFor[nX],aAux)
				aAux := {}
			EndIf
			
			Next nZ
					
		Next nJ
		
	Next nY
	
Next nX


// -----------------------------------------------------------------------
// Fator de multiplicação e Colocação da Nota de cada forncedor
// -----------------------------------------------------------------------

// Todos os Produtos
For nX := 1 To Len(aPrdXFor)
	// Todos os Fornecedores
	For nY := 2 to Len(aPrdXFor[nX]) 
		//Todos os quesitos
		For nZ := 2 to Len(aPrdXFor[nX][nY])
			//Preço
			aPrdXFor[nX][nY][nZ][2] := aPrdXFor[nX][nY][nZ][2] * aPrdMinMax[nX][2][4]
			If (aPrdXFor[nX][nY][nZ][2] < aPrdMinMax[nX][2][5] .And. aPrdXFor[nX][nY][nZ][2] > 0) .Or. aPrdMinMax[nX][2][5] == 0
				aPrdMinMax[nX][2][5] := aPrdXFor[nX][nY][nZ][2]
			EndIf 
			
			//Prazo
			aPrdXFor[nX][nY][nZ][3] := aPrdXFor[nX][nY][nZ][3] * aPrdMinMax[nX][3][4]
			If (aPrdXFor[nX][nY][nZ][3] < aPrdMinMax[nX][3][5] .And. aPrdXFor[nX][nY][nZ][3] > 0)  .Or. aPrdMinMax[nX][3][5] == 0 
				aPrdMinMax[nX][3][5] := aPrdXFor[nX][nY][nZ][3] 
			EndIf
			
			//Nota
			aPrdXFor[nX][nY][nZ][4] := aPrdXFor[nX][nY][nZ][4] * aPrdMinMax[nX][4][4]
			If aPrdXFor[nX][nY][nZ][4] > aPrdMinMax[nX][4][5] .Or. aPrdMinMax[nX][4][5] == 0
				aPrdMinMax[nX][4][5] := aPrdXFor[nX][nY][nZ][4] 
			EndIf
		Next nZ	
	Next nY
Next nX

// -----------------------------------------------------------------------
// Necessário mais uma verificação para aplicação do fator de multiplicação
// após identificação da melhor proposta e aplicação do peso
// -----------------------------------------------------------------------

// Todos os Produtos
For nX := 1 To Len(aPrdXFor)
	// Todos os Fornecedores
	For nY := 2 to Len(aPrdXFor[nX]) 
		//Todos os quesitos
		For nZ := 2 to Len(aPrdXFor[nX][nY])
			//Preço
			aPrdXFor[nX][nY][nZ][2] := If(MV_PAR05==0,0,(aPrdXFor[nX][nY][nZ][2] / aPrdMinMax[nX][2][5]) * MV_PAR05)
			
			//Prazo
			aPrdXFor[nX][nY][nZ][3] := If(MV_PAR06==0,0,(aPrdXFor[nX][nY][nZ][3] / aPrdMinMax[nX][3][5]) * MV_PAR06)
			
			//Nota
			aPrdXFor[nX][nY][nZ][4] := If(MV_PAR07==0,0,(aPrdMinMax[nX][4][5] / aPrdXFor[nX][nY][nZ][4]) * MV_PAR07)
			
			//Soma das Notas
			aPrdXFor[nX][nY][nZ][5] := aPrdXFor[nX][nY][nZ][2] + aPrdXFor[nX][nY][nZ][3] + aPrdXFor[nX][nY][nZ][4] 
		Next nZ	
	Next nY
Next nX


// -----------------------------------------------------------------------
// Escolha do vencedor - Por Item
// obs: Sera verifica os propostas de cada fornecedor por produtos
//	e caso seja encontrada uma proposta melhor a primeira será substituida
// -----------------------------------------------------------------------
If MV_PAR04 == 1
	// Todos os Produtos
	aAux := {}
	For nX := 1 To Len(aPrdXFor)
		nMenPrc := 0 // Menor preco.
		nMenPrz := 0 // Menor prazo.
		nMaiNot := 0 // Maior nota.
		
		aPosPrc := {}
		aPosPrz := {}
		aPosNot := {}
		
		aAux := {}
		aAdd(aForVenc,{aPrdXFor[nX][1]})	
		
		// Todos os Fornecedores
		For nY := 2 to Len(aPrdXFor[nX])
			
			Aadd(aPrdXFor[nX][nY][2], {0, 0, 0}) // Armazena os pesos de cada criterio.
			
			For nC := Len(aPrdXFor[nX]) To 2 Step -1
				
				// Preco.
				If (aPrdXFor[nX][nY][2][2] < aPrdXFor[nX][nC][2][2] .And. aPrdXFor[nX][nY][2][2] < nMenPrc .And. aPrdXFor[nX][nY][2][2] > 0) .Or. nMenPrc == 0  
					
					If aPrdXFor[nX][nY][2][2] > 0
						
						aPrdXFor[nX][nY][2][7][1] := MV_PAR05 // Preco.
						
					EndIf
					
					nMenPrc := aPrdXFor[nX][nY][2][2]
					
					If Len(aPosPrc) > 0
						
						aPrdXFor[aPosPrc[1]][aPosPrc[2]][2][7][1] := 0
						
					EndIf
					
					aPosPrc := {}
					aPosPrc := {nX, nY}
					
				EndIf
				
				// Prazo.
				If (aPrdXFor[nX][nY][2][3] < aPrdXFor[nX][nC][2][3] .And. aPrdXFor[nX][nY][2][3] < nMenPrz .And. aPrdXFor[nX][nY][2][3] > 0) .Or. nMenPrz == 0 
					
					If aPrdXFor[nX][nY][2][3] > 0
						
						aPrdXFor[nX][nY][2][7][2] := MV_PAR06 // Prazo.
						
					EndIf
					
					nMenPrz := aPrdXFor[nX][nY][2][3]
					
					If Len(aPosPrz) > 0
						
						aPrdXFor[aPosPrz[1]][aPosPrz[2]][2][7][2] := 0
						
					EndIf
					
					aPosPrz := {}
					aPosPrz := {nX, nY}
					
				EndIf
				
				// Nota.
				If (aPrdXFor[nX][nY][2][4] > aPrdXFor[nX][nC][2][4] .And. aPrdXFor[nX][nY][2][4] > nMaiNot) .Or. nMaiNot == 0
					
					If aPrdXFor[nX][nY][2][4] > 0
						
						aPrdXFor[nX][nY][2][7][3] := MV_PAR07 // Nota.
						
					EndIf
					
					nMaiNot := aPrdXFor[nX][nY][2][4]
					
					If Len(aPosNot) > 0
						
						aPrdXFor[aPosNot[1]][aPosNot[2]][2][7][3] := 0
						
					EndIf
					
					aPosNot := {}
					aPosNot := {nX, nY}
					
				EndIf
				
				If Len(aPrdXFor[nX][nC][2]) < 7
					
					Aadd(aPrdXFor[nX][nC][2], {0, 0, 0}) // Armazena os pesos de cada criterio.
					
				EndIf
				
				If (aPrdXFor[nX][nY][2][7][1] + aPrdXFor[nX][nY][2][7][2] + aPrdXFor[nX][nY][2][7][3] > aPrdXFor[nX][nC][2][7][1] + aPrdXFor[nX][nC][2][7][2] + aPrdXFor[nX][nC][2][7][3]) .Or. Len(aPrdXFor[nX]) <= 2
					
					aAux := {}
					aAdd(aAux,aPrdXFor[nX][nY][2][5])
					aAdd(aAux,nY)
					
				EndIf
				
			Next nC
			
		Next nY
		
		//Adiciona todos os vencedores no array de vencedores por produto
		//Desconsiderando a primeira posição que a referência do melhor
		For nZ := 1 to Len(aAux)-1 
			aAdd(aForVenc[nX],aPrdXFor[nX][aAux[nZ+1]])
		Next nZ
		
	Next nX
	
	// -----------------------------------------------------------------------
	// Marcação do vencedor
	// -----------------------------------------------------------------------
	For nX := 1 To Len(aForVenc)
		
		If Len(aForVenc[nX]) > 1
			
			/*posição 1, 2, 4 do aPropostas*/
			ANewDesMark(aForVenc[nX][2][2][6][1],aForVenc[nX][2][2][6][2],aForVenc[nX][2][2][6][3],aPropostas,aItens,oBrowse1,oBrowse2,oBrowse3,.T.)
			
		EndIf
		
	Next nX
	
Else
	
	// -----------------------------------------------------------------------
	// Escolha do vencedor - Por Cotação
	// Obs: Será soma a  pontuação de cada fornecedor, formando um Ranking 
	//	com a classificação de todos os fornecedores, dividido pela quantidade
	//	de itens que ele participa
	// -----------------------------------------------------------------------
	
	// Todos os Produtos
	For nX := 1 To Len(aPrdXFor)
		
		// Todos os Fornecedores
		For nY := 2 to Len(aPrdXFor[nX])
			aAux := {}	
			
			If Empty(aRank) .Or. (nZ := aScan(aRank,{|x| x[1] = aPrdXFor[nX][nY][1]+"|"+aPrdXFor[nX][nY][2][1]})) == 0
				
				aAdd(aAux,aPrdXFor[nX][nY][2][5]) //Pontuação
				aAdd(aAux,1)//Quantidade de Itens
				
				aAdd(aRank,{aPrdXFor[nX][nY][1]+"|"+aPrdXFor[nX][nY][2][1],aAux}) // Fornecedor+Proposta
				
			Else
				//Aumenta a pontuação
				aRank[nZ][2][1] := aRank[nZ][2][1] + aPrdXFor[nX][nY][2][5]
				//Aumenta a quantidade de itens
				aRank[nZ][2][2] := aRank[nZ][2][2]++
			EndIf
			
		Next nY
	
	Next nX
	
	aBkpRank := AClone(aRank)
	aRank    := {}
	
	// Somente aceita propostas que atendam todos os produtos.
	For nI := 1 To Len(aBkpRank)
		
		If Len(aItens) == aBkpRank[nI][2][2]
			
			Aadd(aRank, aBkpRank[nI])
			
		EndIf
		
	Next nI
	
	// Divide a pontuação pela quantidade de itens.
	For nX :=1 To len(aRank)
		aRank[nX][2][1] := aRank[nX][2][1] / aRank[nX][2][2]
	Next nX
	
	// Ordena pela maior pontuacao.
	ASORT(aRank, , , { | x,y | x[2][1] < y[2][1] } )
	
	
	// -----------------------------------------------------------------------
	// Marcação do vencedor
	// -----------------------------------------------------------------------
	
	// Todos os Produtos
	For nX := 1 to Len(aPrdXFor)
		lAchou := .F.
		// Verifica os vencedores pela ordem
		For nZ := 1 to Len(aRank)
			// Todos os Fornecedores
			For nY := 2 To Len(aPrdXFor[nX])
				// Compara fornecedor e proposta
				If aPrdXFor[nX][nY][1] == Substr(aRank[nZ][1],1,At("|",aRank[nZ][1])-1) .And. aPrdXFor[nX][nY][2][1] == Substr(aRank[nZ][1],At("|",aRank[nZ][1])+1,Len(aRank[nZ][1]))
					
					ANewDesMark(aPrdXFor[nX][nY][2][6][1],aPrdXFor[nX][nY][2][6][2],aPrdXFor[nX][nY][2][6][3],aPropostas,aItens,oBrowse1,oBrowse2,oBrowse3,.T.)
					lAchou := .T.
					Exit
				EndIf
			Next nZ
			
			// Caso ja tenha marcado o vencedor nao verifica os demais
			If lAchou
				Exit
			EndIf
		Next nY
	Next nX
	
EndIf

oBrowse1:LineRefresh()
oBrowse2:LineRefresh()
oBrowse3:LineRefresh()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} U_ANewMinMax()
Verificação de máximos e minimo para todos os critérios avaliados

@author guilherme.pimentel
 
@Obs Estrutura do Array

aPrdXFor[n,X]: Produto
aPrdXFor[n,X,1]: Maior Nota
aPrdXFor[n,X,2]: Menor Nota
aPrdXFor[n,X,3]: Qtd. Part
aPrdXFor[n,X,4]: Média
aPrdXFor[n,X,5]: Melhor Fator
 
@since 06/11/2015
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
User Function ANewMinMax(aPropostas,aPropAux,aPrdMinMax,nZ)

// -----------------------------------------------------------------------
// Preço
// -----------------------------------------------------------------------
If (Empty(aPrdMinMax[2][1])) .Or. (aPropostas[2][nZ][4] > aPrdMinMax[2][1]) 
	aPrdMinMax[2][1] := aPropostas[2][nZ][4] 
EndIf

If (Empty(aPrdMinMax[2][2])) .Or. (aPropostas[2][nZ][4] < aPrdMinMax[2][2]) 
	aPrdMinMax[2][2] := aPropostas[2][nZ][4] 
EndIf

aPrdMinMax[2][3] := aPrdMinMax[2][3]++

aPrdMinMax[2][4] := (aPrdMinMax[2][1]-aPrdMinMax[2][2])/aPrdMinMax[2][3]

// -----------------------------------------------------------------------
// Prazo
// -----------------------------------------------------------------------
If (Empty(aPrdMinMax[3][1])) .Or. (U_ANewDToI(aPropAux[5]) > aPrdMinMax[3][1]) 
	aPrdMinMax[3][1] := U_ANewDToI(aPropAux[5])
EndIf

If (Empty(aPrdMinMax[3][2])) .Or. (U_ANewDToI(aPropAux[5]) < aPrdMinMax[3][2]) 
	aPrdMinMax[3][2] := U_ANewDToI(aPropAux[5])
EndIf

aPrdMinMax[3][3] := aPrdMinMax[3][3]++ 

aPrdMinMax[3][4] := (aPrdMinMax[3][1]-aPrdMinMax[3][2])/aPrdMinMax[3][3]

// -----------------------------------------------------------------------
// Nota
// -----------------------------------------------------------------------
If (Empty(aPrdMinMax[4][1])) .Or. (SA5->A5_NOTA > aPrdMinMax[4][1]) 
	aPrdMinMax[4][1] := SA5->A5_NOTA 
EndIf

If (Empty(aPrdMinMax[4][2])) .Or. (SA5->A5_NOTA < aPrdMinMax[4][2]) 
	aPrdMinMax[4][2] := SA5->A5_NOTA 
EndIf

aPrdMinMax[4][3] := aPrdMinMax[4][3]++ 

aPrdMinMax[4][4] := (aPrdMinMax[4][1]-aPrdMinMax[4][2])/aPrdMinMax[4][3]

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} U_ANewDToI()
Conversão de Data pra Inteiro

@author guilherme.pimentel
 
@since 11/11/2015
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------

User Function ANewDToI(dDate)
Local nRet := 0
Local nDia := 0
Local nMes := 0
Local nAno := 0 

nDia := Day(dDate)
nMes := Month(dDate) * 30
nAno := Year(dDate) * 365

nRet := nDia + nMes + nAno

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX1()
Ajusta SX1

@author guilherme.pimentel
 
@since 13/11/2015
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Static Function AjustaSX1()

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

// -----------------------------------------------------------------------
// Help
// -----------------------------------------------------------------------
//P.MTU_ANew03.
Aadd( aHelpPor, "Indica se haverá sugestão da melhor ")
Aadd( aHelpPor, "alternativa na cotação.")
Aadd( aHelpEng, "")
Aadd( aHelpSpa, "")

PutHelp("P.MTU_ANew03.",aHelpPor,aHelpEng,aHelpSpa,.T.)

//P.MTU_ANew04.
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}

Aadd( aHelpPor, "Indica a forma de avaliação da melhor proposta ")
Aadd( aHelpPor, "Item: Será marcado o melhor item ")
Aadd( aHelpPor, "individualmente - Proposta: Será marcada a  ")
Aadd( aHelpPor, "melhor proposta como um todo. ")
Aadd( aHelpEng, "")
Aadd( aHelpSpa, "")

PutHelp("P.MTU_ANew04.",aHelpPor,aHelpEng,aHelpSpa,.T.)

//P.MTU_ANew05.
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}

Aadd( aHelpPor, "Peso do critério Preço na verificação ")
Aadd( aHelpPor, " do vencedor.")
Aadd( aHelpEng, "")
Aadd( aHelpSpa, "")

PutHelp("P.MTU_ANew05.",aHelpPor,aHelpEng,aHelpSpa,.T.)

//P.MTU_ANew06.
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}

Aadd( aHelpPor, "Peso do critério Prazo na verificação ")
Aadd( aHelpPor, " do vencedor.")
Aadd( aHelpEng, "")
Aadd( aHelpSpa, "")

PutHelp("P.MTU_ANew06.",aHelpPor,aHelpEng,aHelpSpa,.T.)

//P.MTU_ANew07.
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}

Aadd( aHelpPor, "Peso do critério Nota na verificação ")
Aadd( aHelpPor, " do vencedor.")
Aadd( aHelpEng, "")
Aadd( aHelpSpa, "")

PutHelp("P.MTU_ANew07.",aHelpPor,aHelpEng,aHelpSpa,.T.)

// -----------------------------------------------------------------------
// Pergunte
// -----------------------------------------------------------------------
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}
PutSx1( "MTU_ANew","03","Traz Cotac. Marcada:","Traz Cotac. Marcada:","Traz Cotac. Marcada:","mv_ch3",;
"N",1,0,2,"C","","","","","mv_par03","Sim","Sí","Yes","","Nao","No","No","","","","","","","","","",;
aHelpPor,aHelpEng,aHelpSpa)           


PutSx1( "MTU_ANew","04","Analise de proposta por:","Analise de proposta por:","Analise de proposta por:","mv_ch4",;
"N",1,0,1,"C","","","","","mv_par04","Por Item","Por Item","Por Item","","Por Proposta","Por Proposta","Por Proposta","","","","","","","","","",;
aHelpPor,aHelpEng,aHelpSpa)           


PutSx1( "MTU_ANew","05","Peso Preco:","Peso Preco:","Peso Preco:","mv_ch5",;
"N",1,0,1,"G","","","","","mv_par05","","","","1","","","","","","","","","","","","",;
aHelpPor,aHelpEng,aHelpSpa)           


PutSx1( "MTU_ANew","06","Peso Prazo:","Peso Prazo:","Peso Prazo:","mv_ch6",;
"N",1,0,1,"G","","","","","mv_par06","","","","1","","","","","","","","","","","","",;
aHelpPor,aHelpEng,aHelpSpa)           


PutSx1( "MTU_ANew","07","Peso Nota:","Peso Nota:","Peso Nota:","mv_ch7",;
"N",1,0,1,"G","","","","","mv_par07","","","","1","","","","","","","","","","","","",;
aHelpPor,aHelpEng,aHelpSpa)           


Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} AjustaSX3
Ajusta SX3

@author Carlos Capeli
@since 03/02/2016
@version P12.1.7
*/
//-------------------------------------------------------------------

Static Function AjustaSX3()

	Local aDadosSC8 := {}
	Local nX 		:= 0
	Local cSql		:= ""
	Local cInibrw  	:= 'POSICIONE("SC1",1,XFILIAL("SC1")+SC8->C8_NUMSC+SC8->C8_ITEMSC,"SC1->C1_DESCRI")'

	aDadosSC8 := FWSX3Util():GetListFieldsStruct(cTabAlias,.F.) 
	For nX := 1 To Len(aDadosSC8)
		If aDadosSC8[nX][1] == "C8_DESCRI"
			If cInibrw <> AllTrim(GetSX3Cache(aDadosZ1[1],"X3_INIBRW")) 
				cSql := " UPDATE "+RetSqlName("SX3")
				cSql += " SET X3_INIBRW = '"+cInibrw+"'"
				cSql += " WHERE " 
				cSql += " X3_ARQUIVO = 'SC8' "
				cSql += " AND X3_CAMPO = 'C8_DESCRI' "
				TcSQLExec(cSql)
			EndIf
		EndIf 
	Next nX 
Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} ANewPcoVld
Valida bloqueios na integracao com SIGAPCO

@author Carlos Capeli
@since 13/11/2015
@version P12.1.7
*/
//-------------------------------------------------------------------

Static Function ANewPcoVld(lDeleta)

Local aAreaAnt	:= GetArea()
Local lRetPCO		:= .T.
Local lRetorno	:= .T.
Local nX		:= 0

Default lDeleta := .F.

// Verifica se Solicitacao de Compra possui rateio e gera lancamentos no PCO
SCX->(dbSetOrder(1))
If SCX->(MsSeek(xFilial("SCX")+SC1->(C1_NUM+C1_ITEM)))
	While SCX->(!Eof()) .And. SCX->(CX_FILIAL+CX_SOLICIT+CX_ITEMSOL) == xFilial("SCX")+SC1->(C1_NUM+C1_ITEM)

		lRetPCO := PcoVldLan('000051','03',,,lDeleta)	// Solicitacao de compras - Rateio por CC na cotacao
		If !lRetPCO
			lRetorno := .F.
		EndIf

		SCX->(DbSkip())
	End
EndIf

// Inclusao de pedido de compras por cotacao"
lRetPCO := PcoVldLan('000052','02',,,lDeleta)
If !lRetPCO
	lRetorno := .F.
EndIf

RestArea(aAreaAnt)

Return lRetorno

/*--------------------------------------------
Trata o campo memo de observacao.
--------------------------------------------*/

Static Function TRATAMOT(oDlMemo, oEditor, cTexto)

Local lMot := GetNewPar("MV_MOTIVOK",.F.)

cTexto := oEditor:RetText()

If lMot
	
	If Empty(cTexto)
		
		Alert("STR0090")
		
	Else
		
		oDlMemo:End()
		
	EndIf
	
EndIf

Return

/*--------------------------------------------
Valida a tela de analise da cotacao.
--------------------------------------------*/

Static Function VALIDAOK(aPropostas)

Local aArea    := GetArea()
Local aAreaSc8 := SC8->(GetArea())

Local lRet := .T.
Local lMot := GetNewPar("MV_MOTIVOK",.F.)

Local nP := 0
Local nI := 0
Local nH := 0

For nP := 1 To Len(aPropostas)
	
	For nI := 1 To Len(aPropostas[nP])
		
		For nH := 1 To Len(aPropostas[nP][nI][2])
			
			// Trava no registro da SC8 para verificar se o item ja foi encerrado anteriormente.
			// Caso ja tenha pedido, nao verifica observacao, pois pode ser um encerramento parcial.
			// Ou o parametro pode ser ativo durante o processo de analise da cotacao.
			SC8->(DbGoTo(aPropostas[nP, nI, 2, nH, 9]))
			
			If aPropostas[nP, nI, 2, nH, 1] .And. lMot .And. Empty(aPropostas[nP, nI, 2, nH, 6]) .And. Empty(SC8->C8_NUMPED)
				
				lRet := .F.
				
			EndIf
			
		Next nH
		
	Next nI
	
Next nP

If !lRet
	
	Alert("")
	
EndIf

RestArea(aArea)
RestArea(aAreaSc8)

Return lRet
