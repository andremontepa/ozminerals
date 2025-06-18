#include 'Protheus.ch'
 
user function F290BFIL()
    local cFiltro:= ""

    //Filtra somente titulos INSS e ISS quando executar rotina no Módulo Livros Fiscais
    If nModulo == 9 // Ao acessar Livros Fiscais
    cFiltro := "(ALTRIM(E2_TIPO) = 'INS' OR ALTRIM (E2_TIPO)='ISS') AND E2_BAIXA=' ' "
    endif

Return cFiltro

