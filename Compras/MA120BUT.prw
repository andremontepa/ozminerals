#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include 'TBICONN.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MA120BUT  �Autor  � Toni Aguiar        � Data �  22/09/16   ���
�������������������������������������������������������������������������͹��
���Desc.     � Inclui os bot�es de aprova��o, bloqueio e rejei��o de      ���
���          � no pedido de compras.                                      ���
�������������������������������������������������������������������������͹��
���Uso       � Usado na rotina de aprova��o do ped.na visualiza��do do doc���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MA120BUT                                                                                                 
Local aUButton:={}     
Local cArea:=GetArea()
//Public CXFILTRASCR:=""  
 
If IsInCallStack("MATA094") 
   AADD(aUButton,{"Aprova"  ,  {|| A94ExLiber() }, "Aprova��o", "Aprova Pedido"}) 
   //AADD(aUButton,{"Aprova"  ,  {|| A097Libera() }, "Aprova��o", "Aprova Pedido"}) 
   AADD(aUButton,{"Bloquear",  {|| FFBloqueio() }, "Bloqueio", "Bloquear Pedido"}) 
   //AADD(aUButton,{"Rejeitar",  {|| FFRejeicao() }, "Rejei��o", "Rejeitar Pedido"}) 
Endif 
AADD(aUButton,{"Cotacao",{|| U_MAT161AUX(SC7->C7_NUMCOT,SC7->C7_FILIAL,SC7->C7_NUMSC)},"Cotac�o","Cota��o"})             
RestArea(cArea)
Return aUButton

//--
//-- Toni Aguiar - TOTVS STARSOFT em 22/09/2016
//-- Faz a chamada da fun��o de bloqueio de pedidos
//--
Static Function FFBloqueio()
Local cEmail
	// Chama a rotina de bloqueio
	A094Bloqu()
	
	//Envia e-mail para o usu�rio
	//Pesquisa o endere�o de e-mail do usu�rio que deu origem ao pedido de compras
	cEmail:=SeekEml(SC7->C7_USER) 
	If !Empty(cEmail)
	   EnvEmail(SC7->C7_NUM, cEmail)
	Endif
Return

//--
//-- Toni Aguiar - TOTVS STARSOFT em 31/10/2016
//-- Fun��o que envia o e-mail para o usu�rio que deu origem ao pedido de compras e o informa
//-- que o pedido foi bloqueado/rejeitado.
//--
Static Function EnvEmail(c_Pedido, cEmail)
Local lLast := .T.
Local nTotal := 0   
Local oProcess       
Local oHTML
Local cUsPedido

oProcess:=TWFProcess():New( "000001", "Aprova��o de Pedidos" )		  						//Crio o objeto oProcess, que recebe a inicializa��o da classe TWFProcess. Repare que o primeiro Par�metro � o c�digo do processo que cadastramos acima e o segundo uma descri��o qualquer.
oProcess:NewTask( "000001", "\WORKFLOW\WFW120P.HTM" )										//Crio uma task. Um Processo pode ter v�rias Tasks(tarefas). Para cada Task informo um nome para ela e o HTML envolvido. Repare que o path do HTML � sempre abaixo do RootPath do Microsiga Protheus�.
oProcess:cSubject := "Pedido: "+c_Pedido+", Bloqueado/Rejeitado em "+Dtoc(DDATABASE)		//Informo o t�tulo do e-mail.
oHTML := oProcess:oHTML																		//Simplesmente passo o valor da propriedade oProcess:oHTML  para uma vari�vel local para facilitar

DbSelectArea("SC7")
dbSeek(xFilial("SC7")+c_Pedido)                                                                                         
cUsPedido:=SC7->C7_USER

//Come�o a preencher os valores do HTML. Inicialmente preencho o objeto DATA(no Html %DATA%) com a data base do sistema.
oHtml:ValByName( "EMISSAO", SC7->C7_EMISSAO )
oHtml:ValByName( "FORNECEDOR", SC7->C7_FORNECE )    
oHtml:ValByName( "lb_nome", POSICIONE("SA2",1, xFilial('SA2')+SC7->C7_FORNECE, "A2_NREDUZ") )    
oHtml:ValByName( "lb_cond", POSICIONE("SE4",1, xFilial('SE4')+SC7->C7_COND, "E4_DESCRI") ) 
oHtml:ValByName( "PEDIDO", SC7->C7_NUM )

Do While !Eof() .And. SC7->(C7_FILIAL+C7_NUM) = xFilial("SC7")+c_Pedido
   
   AAdd( (oHtml:ValByName( "it.item" ))  ,SC7->C7_ITEM )		
   AAdd( (oHtml:ValByName( "it.codigo" )),SC7->C7_PRODUTO )		       
   
   dbSelectArea('SB1')
   dbSetOrder(1)
   dbSeek(xFilial('SB1')+SC7->C7_PRODUTO)
   
   AAdd( (oHtml:ValByName( "it.descricao" )),SB1->B1_DESC )		              
   AAdd( (oHtml:ValByName( "it.quant" )),TRANSFORM( SC7->C7_QUANT,'@E 999,999.99' ) )		              
   AAdd( (oHtml:ValByName( "it.preco" )),TRANSFORM( SC7->C7_PRECO,'@E 999,999.99' ) )		                     
   AAdd( (oHtml:ValByName( "it.total" )),TRANSFORM( SC7->C7_TOTAL,'@E 999,999.99' ) )		                     
   AAdd( (oHtml:ValByName( "it.unid" )) ,SB1->B1_UM )		              
   
   nTotal += SC7->C7_TOTAL
   
   dbSelectArea("SC7")
   dbSkip()
Enddo

oHtml:ValByName( "lbValor" ,TRANSFORM( nTotal,'@E 999,999.99' ) )		              	
oHtml:ValByName( "lbFrete" ,TRANSFORM( 0,'@E 999,999.99' ) )		              	    
oHtml:ValByName( "lbTotal" ,TRANSFORM( nTotal,'@E 999,999.99' ) )		              	    
//oHtml:ValByName( "aprovacao" ,"N" )

//Pega o motivo da rejei��o/bloqueio
dbSelectArea("SCR")
dbSetOrder(1)
dbSeek(xFilial("SCR")+"PC"+c_Pedido)
oHtml:ValByName( "lbMotivo", SCR->CR_OBS)

//Informo para qual endere�o(s) vai o e-mail  		 
oProcess:cTo := cEmail
//Coloco aqui um ponto de Rastreabilidade. Os dois primeiros par�metros s�o sempre os abaixo passados e o terceiro indica o c�digo do Status acima cadastrado.
RastreiaWF(oProcess:fProcessID+'.'+oProcess:fTaskID,oProcess:fProcCode,'10001')
//Inicio o Processo, enviando o e-mail.
oProcess:Start()
//finalizo o processo
oProcess:Finish()
Return .T.

//--
//-- Toni Aguiar - TOTVS STARSOFT em 31/10/2016
//-- Retorna ao e-mail do usu�rio que deu origem ao pedido de compras
//--
Static Function SeekEml(cUsPedido)  
Local cMailAp:=""
Local aInfo:={}

PswOrder(1)
If PswSeek(cUsPedido,.T.)
   aInfo   := PswRet(1)
   cMailAp := Alltrim(aInfo[1,14])
   conout ("Email do Usu�rio:" + cMailAp)	   
Endif
Return cMailAp                      