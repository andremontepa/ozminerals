#include "protheus.ch"
#include "tbiconn.ch"


user function pcomfile()

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01'

z := CPYT2S("C:\PCO\pcoedu.dtc","\00\")
//z := CPYS2T("\00\CTDEDU.DTC","C:\TEMP")
//z := CPYS2T("\00\CTHEDU.DTC","C:\TEMP")
//z := CPYS2T("\00\AK5EDU.DTC","C:\TEMP")
final(" ")
return
