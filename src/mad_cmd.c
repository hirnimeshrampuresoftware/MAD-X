#include "madx.h"

static void
store_threader(struct in_cmd* cmd)
{
  threader_par = cmd->clone;
  cmd->clone_flag = 1;
  dump_command(threader_par);
}

void
exec_command(void)
  /* executes one command */
{
  char** toks;
  char* cmd_name;
  struct in_cmd* p = this_cmd;
  struct in_cmd* pp;
  int ret, izero = 0, pos;


  if (p->cmd_def != NULL)
  {
    while (strcmp(p->cmd_def->name, "exec") == 0)
    {
      if ((pos = name_list_pos(p->tok_list->p[p->decl_start],
                               macro_list->list)) > -1)
      {
        exec_macro(p, pos);
        return;
      }
      pp = p;
      if ((p = buffered_cmd(pp)) == pp) break;
    }
    this_cmd = p;
    toks = p->tok_list->p;
    cmd_name = p->cmd_def->name;
    if (strcmp(cmd_name, "stop") == 0 || strcmp(cmd_name, "quit") == 0
        || strcmp(cmd_name, "exit") == 0)
    {
      madx_finish(); stop_flag = 1; return;
    }
    else if (strcmp(cmd_name, "help") == 0) exec_help(p);
    else if (strcmp(cmd_name, "show") == 0) exec_show(p);
    else if (strcmp(cmd_name, "return") == 0)  return_flag = 1;
    else if (strcmp(cmd_name, "value") == 0)
    {
      print_value(p);
    }
    else if (strcmp(cmd_name, "system") == 0)
      ret = system(noquote(toks[p->decl_start]));
    else if (strcmp(cmd_name, "title") == 0)
      title = permbuff(noquote(toks[p->decl_start]));
    else if (strcmp(cmd_name, "resplot") == 0)
    {
      plot_options = delete_command(plot_options);
      set_defaults("setplot");
    }
    else
    {
      if (get_option("trace")) time_stamp(cmd_name);
      /* clones with defaults for most commands */
      if (strcmp(cmd_name, "option") == 0
          && options != NULL)
      {
        set_option("tell", &izero); /* reset every time */
        p->clone = options; p->clone_flag = 1;
      }
      else if (strcmp(cmd_name, "setplot") == 0
               && plot_options != NULL)
      {
        p->clone = plot_options; p->clone_flag = 1;
      }
      else p->clone = clone_command(p->cmd_def);
      scan_in_cmd(p); /* match input command with clone + fill */
      current_command = p->clone;
      if (strcmp(p->cmd_def->module, "control") == 0) control(p);
      else if (strcmp(p->cmd_def->module, "c6t") == 0) conv_sixtrack(p);
      else if (strcmp(p->cmd_def->module, "edit") == 0) seq_edit_main(p);
      else if (strcmp(p->cmd_def->module, "ibs") == 0)
      {
        current_ibs = p->clone;
        pro_ibs(p);
      }
      else if (strcmp(p->cmd_def->module, "aperture") == 0)
      {
        pro_aperture(p);
      }
      else if (strcmp(p->cmd_def->module, "touschek") == 0)
      {
        current_touschek = p->clone;
        pro_touschek(p);
      }
      else if (strcmp(p->cmd_def->module, "makethin") == 0) makethin(p);
      else if (strcmp(p->cmd_def->module, "match") == 0)
      {
        current_match = p->clone; /* OB 23.1.2002 */
        pro_match(p);
      }
      else if (strcmp(p->cmd_def->module, "correct") == 0)
      {
        pro_correct(p);
      }
      else if (strcmp(p->cmd_def->module, "emit") == 0)
      {
        pro_emit(p);
      }
      else if (strcmp(p->cmd_def->module, "sdds") == 0)
      {
#ifdef _ONLINE
        pro_sdds(p);
#else
        warning("ignored, only available in ONLINE model:", "SDDS conversion");
#endif
      }
      else if (strcmp(p->cmd_def->module, "error") == 0)
      {
        current_error = p->clone;
        pro_error(p);
      }
      else if (strcmp(p->cmd_def->module, "ptc_create_universe") == 0)
      {
        if (match_is_on == kMatch_PTCknobs)
        {
          madx_mpk_setcreateuniverse(p);
        }
        else
        {
          w_ptc_create_universe_();
          curr_obs_points = 1;  /* default: always observe at machine end */
        }
      }
      /* export XML */
      else if (strcmp(p->cmd_def->module, "ptc_export_xml") == 0)
      {
	/* command with parameters, decoded by dedicated function in madxn.c */
	pro_ptc_export_xml(p);
      }      
      else if (strcmp(p->cmd_def->module, "ptc_create_layout") == 0)
      {
        if (match_is_on == kMatch_PTCknobs)
        {
          madx_mpk_setcreatelayout(p);
        }
        else
        {
          pro_ptc_create_layout();
          reset_count("normal_results");
          reset_count("ptc_twiss");
/*          exec_delete_table("normal_results");
            exec_delete_table("ptc_twiss");*/
        }
      }
      else if (strcmp(p->cmd_def->module, "ptc_move_to_layout") == 0)
      {
        w_ptc_move_to_layout_();
      }
      else if (strcmp(p->cmd_def->module, "ptc_read_errors") == 0)
      {
        pro_ptc_read_errors();
      }
      else if (strcmp(p->cmd_def->module, "ptc_refresh_k") == 0)
      {
        pro_ptc_refresh_k();
      }
      else if (strcmp(p->cmd_def->module, "ptc_align") == 0)
      {
        w_ptc_align_();
      }
      else if (strcmp(p->cmd_def->module, "ptc_twiss") == 0)
      {

        if (match_is_on == kMatch_PTCknobs)
        {
          madx_mpk_setcalc(p);
        }
        else
        {
          current_twiss = p->clone;
          pro_ptc_twiss();
        }
      }
      else if (strcmp(p->cmd_def->module, "ptc_normal") == 0)
      {
        if (match_is_on == kMatch_PTCknobs)
        {
          madx_mpk_setcalc(p);
        }
        else
        {
          w_ptc_normal_();
        }
      }
      else if (strcmp(p->cmd_def->module, "select_ptc_normal") == 0)
      {
        select_ptc_normal(p);
      }
      else if (strcmp(p->cmd_def->module, "ptc_trackline") == 0)
      {
        pro_ptc_trackline(p);
      }
      else if (strcmp(p->cmd_def->module, "ptc_dumpmaps") == 0)
      {
        ptc_dumpmaps(p);
      }
      else if (strcmp(p->cmd_def->module, "ptc_oneturnmap") == 0)
      {
        ptc_oneturnmap(p);
      }
      else if (strcmp(p->cmd_def->module, "ptc_track") == 0)
      {
        pro_ptc_track(p);
      }
      else if (strcmp(p->cmd_def->module, "ptc_setswitch") == 0)
      {
        pro_ptc_setswitch(p);
      }
      else if (strcmp(p->cmd_def->module, "ptc_select") == 0)
      {
        pro_ptc_select(p);
      }
      else if (strcmp(p->cmd_def->module, "ptc_moments") == 0)
      {
        pro_ptc_moments(p);
      }
      else if (strcmp(p->cmd_def->module, "ptc_select_moment") == 0)
      {
        pro_ptc_select_moment(p);
      }
      else if (strcmp(p->cmd_def->module, "ptc_printparametric") == 0)
      {
        pro_ptc_printparametric(p);
      }
      else if (strcmp(p->cmd_def->module, "ptc_knob") == 0)
      {
        pro_ptc_knob(p);
      }
      else if (strcmp(p->cmd_def->module, "ptc_varyknob") == 0)
      {
        pro_ptc_varyknob(p);
      }
      else if (strcmp(p->cmd_def->module, "ptc_setknobvalue") == 0)
      {
        pro_ptc_setknobvalue(p);
      }
      else if (strcmp(p->cmd_def->module, "ptc_refreshpartables") == 0)
      {
        w_ptc_refreshtables_();
      }
      else if (strcmp(p->cmd_def->module, "ptc_setfieldcomp") == 0)
      {
        pro_ptc_setfieldcomp(p);
      }
      else if (strcmp(p->cmd_def->module, "rviewer") == 0)
      {
        w_ptc_rviewer_();
      }
      else if (strcmp(p->cmd_def->module, "ptc_printframes") == 0)
      {
        pro_ptc_printframes(p);
      }
      else if (strcmp(p->cmd_def->module, "ptc_eplacement") == 0)
      {
        pro_ptc_eplacement(p);
      }
      else if (strcmp(p->cmd_def->module, "ptc_script") == 0)
      {
        pro_ptc_script(p);
      }
      else if (strcmp(p->cmd_def->module, "ptc_open_gino") == 0)
      {
        pro_ptc_open_gino(p);
      }
      else if (strcmp(p->cmd_def->module, "ptc_enforce6d") == 0)
      {
        pro_ptc_enforce6d(p);
      }
      else if (strcmp(p->cmd_def->module, "ptc_observe") == 0)
      {
        ptc_track_observe(p);
      }
      else if (strcmp(p->cmd_def->module, "ptc_start") == 0)
      {
        track_is_on = 1;
        track_start(p->clone);
        p->clone_flag = 1;
        /* w_ptc_start_(); */
      }
      else if (strcmp(p->cmd_def->module, "ptc_track_end") == 0)
      {
        ptc_track_end();
      }
      else if (strcmp(p->cmd_def->module, "ptc_end") == 0)
      {
        if(track_is_on) ptc_track_end();
        w_ptc_end_();
      }
      else if (strcmp(p->cmd_def->module, "sxf") == 0)
      {
        pro_sxf(p);
      }
      else if (strcmp(p->cmd_def->module, "survey") == 0)
      {
        current_survey = p->clone;
        pro_survey(p);
      }
      else if (strcmp(p->cmd_def->module, "track") == 0)
      {
        pro_track(p);
      }
      else if (strcmp(p->cmd_def->module, "twiss") == 0)
      {
        current_twiss = p->clone;
        pro_twiss();
      }
    }
  }
}

struct command*
find_command(char* name, struct command_list* cl)
{
  int pos;
  if ((pos = name_list_pos(name, cl->list)) < 0)
    return NULL;
  return cl->commands[pos];
}

struct command_list*
find_command_list(char* name, struct command_list_list* sl)
{
  int pos;
  if ((pos = name_list_pos(name, sl->list)) < 0)
    return NULL;
  return sl->command_lists[pos];
}

void
remove_from_command_list(char* label, struct command_list* list)
{
  int i;
  if ((i = remove_from_name_list(label, list->list)) > -1)
  {
    if (i < --list->curr)
    {
      delete_command(list->commands[i]);
      list->commands[i] = list->commands[list->curr];
    }
  }
}

void
get_defined_commands(void)
  /* reads + stores the commands defined in madxdict.h */
{
  char rout_name[] = "get_defined_commands";
  int i;
  char** p;
  int n = char_cnt(';', command_def);
  p = (char**) mymalloc(rout_name,n * sizeof(char*));
  p[0] = strtok(command_def, ";");
  for (i = 1; i < n; i++) /* make temporary list - strtok is called again */
    p[i] = strtok(NULL, ";");
  for (i = 0; i < n; i++) store_command_def(p[i]);
  myfree(rout_name, p);
}

int
cmd_match(int cnt, char** toks, int* cmd_pos, int* decl_start)
  /* matches input (user) command with the symbolic description
     from the list in madxl.h and returns is type */
{
  int i, i2, j, k, lp;
  for (i = 0; i < n_match; i++)
  {
    k = 0; lp = -1;
    i2 = t_match[i];
    for (j = s_match[i2]; j < s_match[i2+1]; j++)
    {
      if (k == cnt)  break;
      if (*cmd_match_base[j] == '@')
      {
        if (strcmp(cmd_match_base[j], "@cmd") == 0)
        {
          if ((lp = name_list_pos(toks[k],
                                  defined_commands->list)) < 0) break;
        }
        else if (isalpha(*toks[k]) == 0) break;
      }
      else if (strcmp(cmd_match_base[j], toks[k]) != 0)  break;
      k++;
    }

    if (j == s_match[i2+1]) goto found;
  }
  return -3;
  found:
  *cmd_pos = lp; *decl_start = s_match[i2+1] - s_match[i2];


  return i2;
}

void
scan_in_cmd(struct in_cmd* cmd)
  /* reads a command into a clone of the original */
{
  int cnt = 0, /* gives position in command (from 1) */
      i, k, log, n;
  struct name_list* nl = cmd->clone->par_names;
  for (i = 0; i < nl->curr; i++) nl->inform[i] = 0; /* set when read */
  n = cmd->tok_list->curr;
  i = cmd->decl_start;
  cmd->tok_list->p[n] = blank;
  while (i < n)
  {
    log = 0;
    if (i+1 < n && *cmd->tok_list->p[i] == '-')
    {
      log = 1; i++;
    }
    if (*cmd->tok_list->p[i] != ',')
    {
      if ((k = name_list_pos(cmd->tok_list->p[i],
                             cmd->cmd_def->par_names)) < 0)  /* try alias */
      {
        k = name_list_pos(alias(cmd->tok_list->p[i]), cmd->cmd_def->par_names);
        if (k < 0)
          fatal_error("illegal keyword:", cmd->tok_list->p[i]);
        break;
      }
      else if ((i = decode_par(cmd, i, n, k, log)) < 0)
      {
        fatal_error("illegal format near:", cmd->tok_list->p[-i]);
        break;
      }
      cmd->clone->par_names->inform[k] = ++cnt; /* mark parameter as read */
      if (strcmp(cmd->tok_list->p[i], "true_") == 0
          || strcmp(cmd->tok_list->p[i], "false_") == 0)
         cmd->cmd_def->par->parameters[k]->double_value =
	   cmd->clone->par->parameters[k]->double_value;
    }
    i++;
  }
}

int
make_line(char* statement)
  /* makes a new line from input command, stores name in name list */
{
  struct macro* m;
  char** toks = tmp_l_array->p;
  char *prs, *psem;
  int i, n, rs, re;
  int len = strlen(statement);
  while(len >= aux_buff->max) grow_char_array(aux_buff);
  strcpy(aux_buff->c, statement);
  if ((prs = strchr(aux_buff->c, '=')) == NULL) return -3;
  *prs = '\0'; prs++;
  pre_split(aux_buff->c, l_wrk, 0);
  mysplit(l_wrk->c, tmp_l_array);
  get_bracket_t_range(toks, '(', ')', 0, tmp_l_array->curr-1, &rs, &re);
  if ((n = re - rs - 1) < 0) n = 0; /* number of formal arguments if any */
  m = new_macro(n, 2*strlen(prs), 50);
  strcpy(m->name, toks[0]); rs++;
  for (i = 0; i < n; i++) m->formal->p[i] = permbuff(toks[rs+i]);
  if (n > 0) m->formal->curr = n;
  if ((psem = strchr(prs, ';')) != NULL) *psem = '\0';
  mystrcpy(l_wrk, prs);
  pre_split(l_wrk->c, m->body, 0);
  m->body->curr = strlen(m->body->c);
  mysplit(m->body->c, m->tokens);
  n = 0;
  for (i = 0; i < m->tokens->curr; i++)
  {
    if (*m->tokens->p[i] == '(')  n++;
    else if (*m->tokens->p[i] == ')')  n--;
    else if(i > 0 && *m->tokens->p[i] == '*'
            && isdigit(*m->tokens->p[i-1]) == 0) return -3;
  }
  if (n) return -3; /* bracket closing error */
  add_to_macro_list(m, line_list);
  return 0;
}

int
get_stmt(FILE* file, int supp_flag)
  /* Returns complete command(s) in in->buffers[inbuf_level] */
  /* return value:  0   no more input */
  /*                >0  OK */

{
  struct char_array* ca;
  char *c_st, *c_cc, *c_ex;
  char end = ';';
  int in_comment = 0, spec_test = 0, curl_level = 0, go_cond;
  if (in->buffers[in->curr] == NULL)
    in->buffers[in->curr] = new_in_buffer(IN_BUFF_SIZE);
  ca = in->buffers[in->curr]->c_a;
  ca->curr = 0;
  do /* read lines until complete statement(s) */
  {
    next:
    if (ca->max - ca->curr < MAX_LINE) grow_char_array(ca);
    if (!fgets(&ca->c[ca->curr], MAX_LINE, file)) return 0;
    currentline[in->curr]++;
    if (get_option("echo")) puts(&ca->c[ca->curr]);
    c_cc = mystrstr(&ca->c[ca->curr], "//");
    c_ex = mystrchr(&ca->c[ca->curr], '!');
    c_st = mystrstr(&ca->c[ca->curr], "/*");
    if (c_cc != NULL && c_ex != NULL)
    {
      c_cc = (uintptr_t)c_cc < (uintptr_t)c_ex ? c_cc : c_ex; *c_cc = '\0';
    }
    else if(c_cc != NULL 
	    &&(c_st == NULL || (uintptr_t)c_cc < (uintptr_t)c_st))
    {
      if (c_cc == &ca->c[ca->curr]) goto next;
      else *c_cc = '\0';
    }
    else if(c_ex != NULL
	    &&(c_st == NULL || (uintptr_t)c_ex < (uintptr_t)c_st))
    {
      if (c_ex == &ca->c[ca->curr]) goto next;
      else *c_ex = '\0';
    }
    if (in_comment)
    {
      if (mystrstr(&ca->c[ca->curr], "*/") == NULL)  goto next;
      else
      {
        remove_upto(&ca->c[ca->curr], "*/"); in_comment = 0;
      }
    }
    else if((c_st = mystrstr(&ca->c[ca->curr], "/*")) != NULL)
    {
      if (mystrstr(&ca->c[ca->curr], "*/") == NULL)
      {
        *c_st = '\0'; ca->curr += supp_lt(&ca->c[ca->curr], supp_flag);
        in_comment = 1; goto next;
      }
      else remove_range(&ca->c[ca->curr], "/*", "*/");
    }
    if (spec_test == 0 && mystrchr(&ca->c[ca->curr], '{') != NULL)
    {
      spec_test = 1; if (in_spec_list(ca->c)) end = '}';
    }
    curl_level += char_cnt('{', &ca->c[ca->curr])
      - char_cnt('}', &ca->c[ca->curr]);
    if ((ca->curr += supp_lt(&ca->c[ca->curr], supp_flag)) == 0) go_cond = 1;
    else if ((go_cond = curl_level) == 0)
      go_cond = ca->c[ca->curr-1] == ';' || ca->c[ca->curr-1] == end ? 0 : 1;
  }
  while (go_cond);
  return 1;
}

void
control(struct in_cmd* cmd)
  /* executes so-called "control" commands */
{
  char** toks = cmd->tok_list->p;
  int k = cmd->decl_start - 1;
  if      (strcmp(toks[k], "assign")      == 0) exec_assign(cmd);
  else if (strcmp(toks[k], "beam")        == 0) exec_beam(cmd, 0);
  else if (strcmp(toks[k], "call")        == 0) exec_call(cmd);
  else if (strcmp(toks[k], "option")      == 0) exec_option();
  else if (strcmp(toks[k], "resbeam")     == 0) exec_beam(cmd, 1);
  else if (strcmp(toks[k], "save")        == 0) exec_save(cmd);
  else if (strcmp(toks[k], "delete")      == 0) exec_cmd_delete(cmd);
  else if (strcmp(toks[k], "dumpsequ")    == 0) exec_dumpsequ(cmd);
  else if (strcmp(toks[k], "set")         == 0) store_set(cmd->clone, 1);
  else if (strcmp(toks[k], "sodd")        == 0) exec_sodd(cmd);
  else if (strcmp(toks[k], "threader")    == 0) store_threader(cmd);
  else if (strcmp(toks[k], "use")         == 0) use_sequ(cmd);
  else if (strcmp(toks[k], "write")       == 0) exec_dump(cmd);
  else if (strcmp(toks[k], "beta0")       == 0) store_beta0(cmd);
  else if (strcmp(toks[k], "coguess")     == 0) exec_store_coguess(cmd);
  else if (strcmp(toks[k], "create")      == 0) exec_create_table(cmd);
  else if (strcmp(toks[k], "fill")        == 0) exec_fill_table(cmd);
  else if (strcmp(toks[k], "setvars")     == 0) exec_setvars_table(cmd);
  else if (strcmp(toks[k], "extract")     == 0) exec_extract(cmd);
  else if (strcmp(toks[k], "plot")        == 0) exec_plot(cmd);
  else if (strcmp(toks[k], "print")       == 0) exec_print(cmd);
  else if (strcmp(toks[k], "readtable")   == 0) read_table(cmd);
  else if (strcmp(toks[k], "savebeta")    == 0) store_savebeta(cmd);
  else if (strcmp(toks[k], "select")      == 0) store_select(cmd);
  else if (strcmp(toks[k], "deselect")    == 0) store_deselect(cmd);
  puts("++++++++++++++ command skipped in parser version");
  /* insert your proper command action here */
}

int 
decode_command(void)  /* compares command with templates, fills this_cmd
                         return: 0 command from list (except below);
                         1 element definition (as well inside sequence);
                         2 variable definition;
                         3 sequence or endsequence;
                         4 element reference inside sequence (no def.);
                         -1 illegal in this context or form;
                         -2 label is protected keyword;
                         -3 statement not recognised */
{


  int i, aux_pos, cmd_pos, decl_start, type;
  int n = this_cmd->tok_list->curr;
  char** toks = this_cmd->tok_list->p;
  this_cmd->type = -3;
  if ((i = cmd_match(n, toks, &cmd_pos, &decl_start)) < 0)  return i;


  this_cmd->sub_type = i;
  this_cmd->decl_start = decl_start;
  switch (i)
  {
    case 0:
      if (n > 1 && *toks[1] == ':') /* label is (protected) key */ return -2;
      this_cmd->cmd_def = defined_commands->commands[cmd_pos];
      if (strcmp(toks[0], "endsequence") == 0)
      {
        if (sequ_is_on == 0) return -1;
        this_cmd->type = 3;
        sequ_is_on = 0;
      }
      else if (strcmp(this_cmd->cmd_def->module, "element") == 0
               || strcmp(this_cmd->cmd_def->module, "sequence") == 0) return -1;
      else this_cmd->type = 0;
      break;
    case 1:
    case 16:
      if (i == 1) aux_pos = 0;
      else          aux_pos = 1;
      this_cmd->cmd_def = defined_commands->commands[cmd_pos];
      this_cmd->type = 0;
      this_cmd->label = permbuff(toks[aux_pos]);
      if (strcmp(this_cmd->cmd_def->module, "element") == 0)
        this_cmd->type = 1; /* element definition */
      else if (strcmp(this_cmd->cmd_def->module, "sequence") == 0)
      {
        if (strcmp(toks[aux_pos+2], "sequence") == 0)
        {
          this_cmd->type = 3;
          sequ_is_on = 1;
        }
        else return -1;
      }
      type = this_cmd->cmd_def->link_type;
      if (type == 1)
      {
        if (group_is_on || sequ_is_on) return -1; /* group in group illegal */
        group_is_on = 1;
        current_link_group = this_cmd->cmd_def->group;
      }
      else if (group_is_on)
      {
        if (strcmp(none, this_cmd->cmd_def->group) != 0
            && strcmp(current_link_group, this_cmd->cmd_def->group) != 0)
          return -1; /* command does not belong to this group */
        if (type == 2)
        {
          current_link_group = none; /* end of group */
          group_is_on = 0;
        }
      }
      break;
    case 14:
      this_cmd->type = 1;
      this_cmd->decl_start++; /* skip (as yet unknown) element class pos. */
      break;
    case 15:
      this_cmd->type = 4; /* element or sequence reference inside sequence
                             or element parameter definition */
      this_cmd->decl_start--; /* second name is already declaration start */
      break;
    default:
      type = 0;
      this_cmd->type = 2;
  }
  return this_cmd->type;
}

struct command*
clone_command(struct command* p)
{
  int i;
  struct command* clone = new_command(p->name, 0, p->par->curr,
                                      p->module, p->group, p->link_type,
                                      p->mad8_type);
  copy_name_list(clone->par_names, p->par_names);
  clone->par->curr = p->par->curr;
  for (i = 0; i < p->par->curr; i++)
    clone->par->parameters[i] =
      clone_command_parameter(p->par->parameters[i]);
  return clone;
}

struct command*
new_command(char* name, int nl_length, int pl_length, char* module, char* group, int link, int mad_8)
{
  char rout_name[] = "new_command";
  char loc_name[2*NAME_L];
  struct command* new
    = (struct command*) mycalloc(rout_name,1, sizeof(struct command));
  strcpy(loc_name, name); strcat(loc_name, "_param");
  new->stamp = 123456;
  strcpy(new->name, name);
  if (watch_flag) fprintf(debug_file, "creating ++> %s\n", loc_name);
  strcpy(new->module, module);
  strcpy(new->group, group);
  new->link_type = link;
  new->mad8_type = mad_8;
  if (nl_length == 0) nl_length = 1;
  new->par_names = new_name_list(loc_name, nl_length);
  new->par = new_command_parameter_list(pl_length);
  return new;
}

struct command_list*
new_command_list(char* l_name, int length)
{
  char rout_name[] = "new_command_list";
  struct command_list* il =
    (struct command_list*) mycalloc(rout_name,1, sizeof(struct command_list));
  strcpy(il->name, l_name);
  il->stamp = 123456;
  if (watch_flag) fprintf(debug_file, "creating ++> %s\n", il->name);
  il->curr = 0;
  il->max = length;
  il->list = new_name_list(il->name, length);
  il->commands
    = (struct command**) mycalloc(rout_name,length, sizeof(struct command*));
  return il;
}

struct command_list_list*
new_command_list_list(int length)
{
  char rout_name[] = "new_command_list_list";
  struct command_list_list* il =
    (struct command_list_list*)
    mycalloc(rout_name,1, sizeof(struct command_list_list));
  strcpy(il->name, "command_list_list");
  il->stamp = 123456;
  if (watch_flag) fprintf(debug_file, "creating ++> %s\n", il->name);
  il->curr = 0;
  il->max = length;
  il->list = new_name_list(il->name, length);
  il->command_lists
    = (struct command_list**)
    mycalloc(rout_name,length, sizeof(struct command_list*));
  return il;
}

struct command_list_list*
delete_command_list_list( struct command_list_list* ll)
{
  char rout_name[] = "delete_command_list_list";
  
  int i;
  
  if (ll == 0x0) return 0x0;
  
  for (i = 0; i < ll->curr; i++)
  {
    delete_command_list(ll->command_lists[i]);
  }

  myfree(rout_name, ll->command_lists );
  
  delete_name_list(ll->list);

  myfree(rout_name, ll );

  return 0x0;
}

struct command*
delete_command(struct command* cmd)
{
  char rout_name[] = "delete_command";
  if (cmd == NULL) return NULL;
  if (stamp_flag && cmd->stamp != 123456)
    fprintf(stamp_file, "d_c double delete --> %s\n", cmd->name);
  if (watch_flag) fprintf(debug_file, "deleting --> %s\n", cmd->name);
  if (cmd->par != NULL)  delete_command_parameter_list(cmd->par);
  if (cmd->par_names != NULL) delete_name_list(cmd->par_names);
  myfree(rout_name, cmd);
  return NULL;
}

struct command_list*
delete_command_list(struct command_list* cl)
{
  char rout_name[] = "delete_command_list";
  int i;
  if (cl == NULL) return NULL;
  if (stamp_flag && cl->stamp != 123456)
    fprintf(stamp_file, "d_c_l double delete --> %s\n", cl->name);
  if (watch_flag) fprintf(debug_file, "deleting --> %s\n", cl->name);
  if (cl->list != NULL) delete_name_list(cl->list);
  for (i = 0; i < cl->curr; i++) delete_command(cl->commands[i]);
  if (cl->commands) myfree(rout_name, cl->commands);
  myfree(rout_name, cl);
  return NULL;
}

void
grow_command_list(struct command_list* p)
{
  char rout_name[] = "grow_command_list";
  struct command** c_loc = p->commands;
  int j, new = 2*p->max;

  p->max = new;
  p->commands
    = (struct command**) mycalloc(rout_name,new, sizeof(struct command*));
  for (j = 0; j < p->curr; j++) p->commands[j] = c_loc[j];
  myfree(rout_name, c_loc);
}

void
grow_command_list_list(struct command_list_list* p)
{
  char rout_name[] = "grow_command_list_list";
  struct command_list** c_loc = p->command_lists;
  int j, new = 2*p->max;

  p->max = new;
  p->command_lists = (struct command_list**)
    mycalloc(rout_name,new, sizeof(struct command_list*));
  for (j = 0; j < p->curr; j++) p->command_lists[j] = c_loc[j];
  myfree(rout_name, c_loc);
}

void
store_command_def(char* cmd_string)  /* processes command definition */
{
  int i, n, j, b_s = 0, r_start, r_end, b_cnt;
  struct element* el;
  struct command* cmd;
  struct command_parameter* p;
  struct in_cmd* tmp_cmd = new_in_cmd(1000);
  struct char_p_array* toks = tmp_cmd->tok_list;

  pre_split(cmd_string, work, 0);
  n = mysplit(work->c, toks);
  if (n < 6 || *toks->p[1] != ':') fatal_error("illegal command:", cmd_string);
  if (defined_commands->curr == defined_commands->max)
    grow_command_list(defined_commands);
  cmd = defined_commands->commands[defined_commands->curr++] =
    new_command(toks->p[0], 40, 40, toks->p[2], toks->p[3],
                atoi(toks->p[4]), atoi(toks->p[5]));

/*
  printf("skowrondebug: store_command_def.c command name %s\n",cmd->name);
  if (strcmp(cmd->name,"twcavity") == 0)
  {
  printf("skowrondebug: store_command_def.c I have got TWCAVITY\n");
  }
*/
  i = add_to_name_list(cmd->name, 0, defined_commands->list);
  if (n > 6)
  {
    b_cnt = string_cnt('[', n, toks->p);
    for (i = 0; i < b_cnt; i++)  /* loop over parameter definitions */
    {
      get_bracket_t_range(toks->p, '[', ']', b_s, n, &r_start, &r_end);
      if (r_start < b_s || r_end - r_start < 2)
        fatal_error("empty or illegal cmd parameter definition:",
                    cmd->name);
      if (cmd->par->curr == cmd->par->max)
        grow_command_parameter_list(cmd->par);
      p = store_comm_par_def(toks->p, r_start+1, r_end-1);
      if (p == NULL) fatal_error("illegal cmd parameter definition:",
                                 cmd->name);
      cmd->par->parameters[cmd->par->curr++] = p;
      j = add_to_name_list(p->name, 1, cmd->par_names);
      b_s = r_end + 1;
    }
  }
  if (strcmp(toks->p[2], "element") == 0)
    el = make_element(toks->p[0], toks->p[0], cmd, 0);
  delete_in_cmd(tmp_cmd);
}

void
add_to_command_list(char* label, struct command* comm, struct command_list* cl, int flag)
  /* adds command comm to the command list cl */
  /* flag for printing a warning */
{
  int pos, j;
  if ((pos = name_list_pos(label, cl->list)) > -1)
  {
    if (flag) put_info(label, "redefined");
    if (cl != defined_commands && cl != stored_commands)
      delete_command(cl->commands[pos]);
    cl->commands[pos] = comm;
  }
  else
  {
    if (cl->curr == cl->max) grow_command_list(cl);
    j = add_to_name_list(permbuff(label), 0, cl->list);
    cl->commands[cl->curr++] = comm;
  }
}

void
add_to_command_list_list(char* label, struct command_list* cl, struct command_list_list* sl)
  /* adds command list cl to command-list list sl */
{
  int pos, j;
  if ((pos = name_list_pos(label, sl->list)) > -1)
  {
    delete_command_list(sl->command_lists[pos]);
    sl->command_lists[pos] = cl;
  }
  else
  {
    if (sl->curr == sl->max) grow_command_list_list(sl);
    j = add_to_name_list(permbuff(label), 0, sl->list);
    sl->command_lists[sl->curr++] = cl;
  }
}

void
dump_command(struct command* cmd)
{
  int i;
  fprintf(prt_file, "command: %s  module: %s\n",
          cmd->name, cmd->module);
  for (i = 0; i < cmd->par->curr; i++)
    dump_command_parameter(cmd->par->parameters[i]);
}

void
print_command(struct command* cmd)
{
  int i;
  fprintf(prt_file, "command: %s\n", cmd->name);
  for (i = 0; i < cmd->par->curr; i++)
  {
    print_command_parameter(cmd->par->parameters[i]);
    if ((i+1)%3 == 0) fprintf(prt_file, "\n");
  }
  if (i%3 != 0) fprintf(prt_file, "\n");
}

