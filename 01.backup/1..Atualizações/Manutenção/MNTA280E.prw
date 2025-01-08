/* Ponto de Entrada para validar se o usuário poderá excluir a SS.

Data: 09/2022
Autor: Sinval

o Parâmetro MV_XUSRSS deve constar o código do usuário
exemplo: Administrador = 000000
*/

#INCLUDE "TOTVS.CH"

user function MNTA280E()

    Local lRet := .F.
    
    if AllTrim(TQB->TQB_CDSOLI) != AllTrim(__cUserID)
        if alltrim(__cUserID) $ GETMV("MV_XUSRSS")
            lRet := .T.
        else
            MsgInfo("Usuário sem Permissão para Exclusão desta SS","Atenção")
        Endif
    else
        lRet := .T.
    endif

return(lRet)
