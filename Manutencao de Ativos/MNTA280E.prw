/* Ponto de Entrada para validar se o usu�rio poder� excluir a SS.

Data: 09/2022
Autor: Sinval

o Par�metro MV_XUSRSS deve constar o c�digo do usu�rio
exemplo: Administrador = 000000
*/

#INCLUDE "TOTVS.CH"

user function MNTA280E()

    Local lRet := .F.
    
    if AllTrim(TQB->TQB_CDSOLI) != AllTrim(__cUserID)
        if alltrim(__cUserID) $ GETMV("MV_XUSRSS")
            lRet := .T.
        else
            MsgInfo("Usu�rio sem Permiss�o para Exclus�o desta SS","Aten��o")
        Endif
    else
        lRet := .T.
    endif

return(lRet)
