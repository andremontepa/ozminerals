//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"

/*---------------------------------------------------------------------------------------------------------------------------*
 | P.E.:  FA080PCC                                                                                                            |
 | Autor: Stephen Noel - Equilibrio                                                                                          |
 | Data:  04/05/2023                                                                                                         |
 | Desc:  Ponto de entrada MVC na rotina manutenção contratos                                                                |
 *---------------------------------------------------------------------------------------------------------------------------*/

User Function RelATF()
    Local aArea        := GetArea()
	Local cQuery        := ""
	Local oFWMsExcel
	Local oExcel
	Local cArquivo    := GetTempPath()+'RelATF'

    




