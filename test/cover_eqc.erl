%% Test that Erlang cover tool can compile any valid Erlang program

-module(cover_eqc).

-include_lib("eqc/include/eqc.hrl").
-compile(export_all).

-define(TEST_MODULE, myerlangprog).

%% Cover compile cover with eqc_cover
%% Tricky, since cover.erl has its own parse transform

compile() ->
  {Path,_} = filename:find_src(cover),
  Options = os:getenv("ERL_COMPILER_OPTIONS"),
  os:putenv("ERL_COMPILER_OPTIONS","[]"),
  compile:file(Path, ['P']),  %% compile with parse_transform
  ok = file:rename("cover.P","cover.erl"),
  case Options of 
    false -> os:putenv("ERL_COMPILER_OPTIONS","[]");
    _ -> os:putenv("ERL_COMPILER_OPTIONS",Options)
  end,
  compile:file("cover.erl",[{parse_transform,eqc_cover}]).


prop_cover() ->
  ?FORALL(Code, eqc_erlang_program:module(?TEST_MODULE,[{maps,true},{macros,true}]),
	  begin
	    File = lists:concat([?TEST_MODULE, ".erl"]),
	    file:write_file(File, Code),
	    Res      = (catch cover:compile(File)),
	    Expected = {ok, ?TEST_MODULE},
	    ?WHENFAIL(eqc:format("~s\n", [Code]),
		      equals(Res, Expected))
	  end).
