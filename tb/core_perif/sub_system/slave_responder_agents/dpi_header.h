#ifndef DPI_DPI_HEADER_H
#define DPI_DPI_HEADER_H

#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

DPI_DLLISPEC void VerilogDPIExpInitCall( const char* _subprogram_name, const char* _description, ... );

static void m__uvm_report_dpi(int32_t _severity, const char* _id, const char* _message, int32_t _verbosity, const char* _filename, int32_t _line)
{
	VerilogDPIExpInitCall("m__uvm_report_dpi","IISISUISUIISISUIIS.",_severity,_id,_message,_verbosity,_filename,_line);
}

#ifdef __cplusplus
}
#endif
#endif
