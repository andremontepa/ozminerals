#Include "TOTVS.ch"
/*---------------------------------------------------------------------*
 | Func:  MT105MNU                                                      |
 | Autor: Lucas Raminelli                                               |
 | Data:  22/04/2025                                                    |
 | Desc:  MT105MNU - Adiciona botÃµes ao menu principal                  |
 | Obs.:  CRM SERVICES                                                  |
 *---------------------------------------------------------------------*/
User Function MT105MNU()

    Local aRet := {}          
    aAdd(aRet, {'#Solicitacao de Armazem',"U_MATR106()"		, 0 , 1, 0, .F.}  )
    
    
Return aRet
