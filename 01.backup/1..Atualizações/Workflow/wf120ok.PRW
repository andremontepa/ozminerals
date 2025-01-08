#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WF120ok   ºAutor  ³Ismael Junior       ºData  ³  18/10/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Envia workflow ao gestor do centro de custos.               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACOM 												      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User function WF120ok(aDados)
Local oHTML
Local _cSol     := cUserName
Local nX        := 0
PswOrder(2)    // ordenado pelo nome
If PswSeek(_cSol, .T. )
	aInfo := PswRet()
	cIDSolicit  := alltrim(aInfo[1][1])
	cEmailSoli  := Alltrim(aInfo[1][14])
EndIf
For nX := 1 To Len(aDados)
//Busca os aprovadores selecionados
cQuery := " SELECT TOP 1 ZW4_EMAIL EMAIL "
cQuery += " FROM "+RetSqlName("ZW4")+" ZW4 "
cQuery += " INNER JOIN "+RetSqlName("ZW5")+" ZW5 ON ZW4_NUM = ZW5_NUM AND ZW5.D_E_L_E_T_ != '*' "
cQuery += " WHERE ZW5_CCUSTO = '"+aDados[nX][1]+"' "
cQuery += " AND ZW4.D_E_L_E_T_ != '*' "

If SELECT("TMP") > 0
	TMP->(DbCloseArea())
Endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)

DbSelectArea("TMP")
TMP->(dbGoTop())

//Crio o objeto oProcess, que recebe a inicialização da classe TWFProcess. Repare que o primeiro Parâmetro é o código do processo que cadastramos acima e o segundo uma descrição qualquer.
oProcess := TWFProcess():New( "000002", "Workflow" )
//Crio uma task. Um Processo pode ter várias Tasks(tarefas). Para cada Task informo um nome para ela e o HTML envolvido. Repare que o path do HTML é sempre abaixo do RootPath do Microsiga Protheus®.
oProcess:NewTask( "000002", "\WORKFLOW\wf120ok.HTML" )
//Informo o título do e-mail.
oProcess:cSubject := "Pedido de compra - sem saldo para liberação "
//Simplesmente passo o valor da propriedade oProcess:oHTML  para uma variável local para facilitar
oHTML := oProcess:oHTML
//Começo a preencher os valores do HTML. Inicialmente preencho o objeto DATA(no Html %DATA%) com a data base do sistema.
oHTML:ValByName('DATA',DATE())
oHTML:ValByName('NOMESOL',_cSol)   
oHTML:ValByName('MAILSOL',cEmailSoli)
oHTML:ValByName('NUMPED',aDados[nX][4])

aadd((oHtml:valByName('TB.CHAVE')),aDados[nX][2])
//aadd((oHtml:valByName('TB.DATA')),DTOC(STOD(TMP->C7_EMISSAO)))
aadd((oHtml:valByName('TB.VALOR')),Transform(aDados[nX][3],"@E 999,999,999.99")) 
aadd((oHtml:valByName('TB.SALDO')),Transform(aDados[nX][5],"@E 999,999,999.99"))

//Informo para qual endereço(s) vai o e-mail
oProcess:cTo := TMP->EMAIL
//oProcess:cCc := "euridice@grupoheringer.com.br;raquel@grupoheringer.com.br" //Alltrim(GetMV("MV_CMCONTR"))

//Coloco aqui um ponto de Rastreabilidade. Os dois primeiros parâmetros são sempre os abaixo passados e o terceiro indica o código do Status acima cadastrado.
RastreiaWF(oProcess:fProcessID+'.'+oProcess:fTaskID,oProcess:fProcCode,'100002')

//Inicio o Processo, enviando o e-mail.
oProcess:Start()
Next nX

TMP->(DbCloseArea())
Return .T.
