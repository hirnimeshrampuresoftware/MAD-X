#ifndef MADX_H
#define MADX_H

// standard headers

#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#ifdef _WIN32
typedef size_t uintptr_t;
#else
#include <stdint.h>
#endif

#ifdef _ICC
// problem with non-standard Intel names in math.h
#define compound(a,b) compound_intel(a,b)
#include <math.h>
#undef  compound
#else
#include <math.h>
#endif

// defines

#include "mad_def.h"
#include "mad_main.h"

// fortran externs

#include "mad_extrn_f.h"

// constants modules

#include "mad_dict.h"

// types modules

#include "mad_cst.h"
#include "mad_var.h"
#include "mad_name.h"
#include "mad_expr.h"
#include "mad_const.h"

#include "mad_rpn.h"
#include "mad_eval.h"
#include "mad_exec.h"
#include "mad_array.h"
#include "mad_logic.h"
#include "mad_macro.h"
#include "mad_parse.h"
#include "mad_range.h"
#include "mad_regex.h"
#include "mad_select.h"
#include "mad_stream.h"

// core modules

#include "mad_err.h"
#include "mad_mem.h"
#include "mad_out.h"
#include "mad_str.h"
#include "mad_vec.h"
#include "mad_core.h"
#include "mad_math.h"
#include "mad_rand.h"
#include "mad_plot.h"
#include "mad_time.h"
#include "mad_util.h"
#include "mad_help.h"

// command modules

#include "mad_cmd.h"
#include "mad_cmdin.h"
#include "mad_cmdpar.h"
#include "mad_option.h"

// sequence modules

#include "mad_seq.h"
#include "mad_node.h"
#include "mad_beam.h"
#include "mad_table.h"

// elements modules

#include "mad_elem.h"
#include "mad_elemdrift.h"
#include "mad_elemmultp.h"
#include "mad_elemerr.h"
#include "mad_elemprobe.h"
#include "mad_elemrfc.h"

// physics modules

#include "mad_aper.h"
#include "mad_dynap.h"
#include "mad_emit.h"
#include "mad_ibs.h"
#include "mad_match.h"
#include "mad_match2.h"
#include "mad_mkthin.h"
#include "mad_orbit.h"
#include "mad_survey.h"
#include "mad_touschek.h"
#include "mad_track.h"
#include "mad_twiss.h"

// ptc interface modules

#include "mad_ptc.h"
#include "mad_ptcknobs.h"

// I/O interface modules

#include "mad_sxf.h"
#include "mad_sdds.h"
#include "mad_sodd.h"
#include "mad_6track.h"

// global constants (should disappear)

#include "mad_gcst.h"

// global variables (should disappear)

#include "mad_gvar.h"

#endif