#INCLUDE "TOPCONN.CH"
#INCLUDE "rwmake.ch"
#include "PROTHEUS.CH"

User Function MA020TOK()
Local lRet := .F.
Local OZUSERloG := RetCodUsr() 
Local OZUserSa2 := SuperGetMV("MV_OZUSRA2")

iF !Empty(M->A2_MSBLQL) 

    If OZUSERloG $ OZUserSa2 .and. Altera  
        lRet := .T. 
    EndIf

    If !lREt .and. M->A2_MSBLQL == "1" .and. !(OZUSERloG $ OZUserSa2)
        FWAlertInfo("Forncedor bloqueado, verifique com o Fiscal", "Fornecedor Bloqueado")
        ProcSa2()
        lRet := .T. 
    EndIF

EndIf
   lRet := .T. 
Return(lRet)


User Function OZCRMSA2() 
Local lRet := .F.

Return(lRet)
*/
//=============================================================================================================================
    Static Function ProcSa2()
//=============================================================================================================================

    Local cMsgHtml  := ""
    Local cPara     := ""
    Local OZUserSa3 := SuperGetMV("MV_OZUSRA2")
    Local aDad1  := Separa(OZUserSa3, '|', .T.)
    Local X := 0
          
    For x := 1 To len(aDad1)
        cPara    += UsrRetMail(aDad1[X]) 
        IF X < len(aDad1)
            cPara += ";"
        EndIF
    Next x
    
    cMsgHtml := GetHtml()
    //cPara    := UsrRetMail(SC1->C1_USER)

    if Empty(cPara)
        MSGALERT( "Usuario nùo possui e-mail sem envio de e-mail.", "ATENùùO" )
    elseif .not. Empty(cMsgHtml)
        //EnviarEmail(cPara,"Exclusùo da Solicitaùùo de Compras - "+Alltrim(cNumSC),cMsgHtml,"")
        U_EnviEmail("",AllTrim(cFilAnt)+" - Fornecedor  - "+Alltrim(M->A2_COD)+"- lOJA -"+ alltrim(M->A2_LOJA),"Bloqueio de Fornecedor para analise. ",cMsgHtml,.F.,cPara,"")
    EndIf 
    //oDlg:End()
Return Nil 

//=============================================================================================================================
    Static Function GetHtml()
//=============================================================================================================================

    Local cHtml     := ""
    Local aAreaA2 := SA2->(GetArea())
    Local cCodUsr := RetCodUsr()
    Local cNomUsr := UsrRetName(cCodUsr)
    Local cTitulo := "Bloqueio de  Fornecedor para analise Fiscal, Revisar Cadastro"

 
    //Monta o corpo do e-Mail que serù enviado
    cHtml  := ''
    cHtml  += ' <html>' + CRLF
    cHtml  += ' <head>' + CRLF
    cHtml  += '     <title>' + cTitulo + '</title>' + CRLF
    cHtml  += ' </head>' + CRLF
    cHtml  += ' <body>' + CRLF
    cHtml  += '     <center><h1>' + cTitulo + '</h1></center>' + CRLF
    cHtml  += '     Hoje, o usuùrio <b>' + Alltrim(cNomUsr) + '</b> incluiu um novo fornecedor no Sistema, abaixo os detalhes do Fornecedor:<br>' + CRLF
    cHtml  += '     <br>' + CRLF
    cHtml  += '     <b>Cùdigo do Fornecedor:</b> ' + SA2->A2_COD      + '<br>' + CRLF
    cHtml  += '     <b>Loja do Fornecedor:</b> '   + SA2->A2_LOJA     + '<br>' + CRLF
    cHtml  += '     <b>CNPJ:</b> '                 + SA2->A2_CGC      + '<br>' + CRLF
    cHtml  += '     <b>Razao Social:</b> '         + SA2->A2_NOME     + '<br>' + CRLF
    cHtml  += '     <b>Nome Fantasia:</b> '        + SA2->A2_NREDUZ   + '<br>' + CRLF
    cHtml  += '     <b>Endereco:</b> '             + SA2->A2_END      + '<br>' + CRLF
    cHtml  += '     <b>Bairro:</b> '               + SA2->A2_BAIRRO   + '<br>' + CRLF
    cHtml  += '     <b>Estado:</b> '               + SA2->A2_EST      + '<br>' + CRLF
    cHtml  += '     <b>Codigo do Municipio:</b> '  + SA2->A2_COD_MUN  + '<br>' + CRLF
    cHtml  += '     <b>Municipio:</b> '            + SA2->A2_MUN      + '<br>' + CRLF
    cHtml  += '     <b>CEP:</b> '                  + SA2->A2_CEP      + '<br>' + CRLF
    cHtml  += '     <b>Telefone:</b> '             + SA2->A2_TEL      + '<br>' + CRLF
    cHtml  += '     <b>Conta Contùbil:</b> '       + SA2->A2_CONTA    + '<br>' + CRLF
    cHtml  += '     <br>' + CRLF
    cHtml  += '     <br>' + CRLF
    cHtml  += '     --<br>' + CRLF
    cHtml  += '     <font size="1">e-Mail gerado automaticamente pelo Protheus - ' + dToC(Date()) + ' - ' + Time() + '</font><br>' + CRLF
    cHtml  += ' </body>' + CRLF
    cHtml  += ' </html>' + CRLF
     
    RestArea(aAreaA2)

Return cHtml
