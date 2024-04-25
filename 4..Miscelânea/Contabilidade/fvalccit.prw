/* Função para validação nos campos de CC  e Item Contábil, nas seguintes tabelas

SD1, CT2, SD3, SC1, SC7
Sinval
03/2023

*/

#include "TOTVS.CH"

user function fvalccit(cTabela,cCampo)
    Local lRet      := .T.
    Local cFilmov   := ""

    if cTabela == "CTT"
        cFilMov := alltrim(Posicione("CTT",1,XFILIAL("CTT")+M->&cCampo,"CTT_XFILMOV"))

        if !empty(cFilMov) 
            if cFilmov <> cFilAnt
                Alert("Atenção Centro de Custo, não pode ser utilizado nesta filial","OK")
                lRet := .F.
            endif
        endif

    elseif cTabela == "CTD"
            cFilMov := alltrim(Posicione("CTD",1,XFILIAL("CTD")+M->&cCampo,"CTD_XFILMOV"))
            
            if !empty(cFilMov) 
                if cFilmov <> cFilAnt
                    Alert("Atenção Item Contábil, não pode ser utilizado nesta filial","OK")
                    lRet := .F.
                endif
            endif
    endif

return(lRet)
