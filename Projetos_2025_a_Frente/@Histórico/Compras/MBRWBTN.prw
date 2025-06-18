#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "RWMAKE.CH"
#Include 'TOTVS.ch'
#Include 'TBICONN.CH'
User Function MBRWBTN()
    Local lRet := .T.
    Local cUsrPerm := GetMv("CF_USRPERM")
    Local cUsuario := RETCODUSR()
 
    IF FunName()=="MATA020"
        If !(cUsuario $ cUsrPerm)
            ApMsgalert('Usuario sem acesso a rotina gentileza acionar o setor de compras','Atencao')
            lRet := .F.
        Endif
    Endif
Return lRet
