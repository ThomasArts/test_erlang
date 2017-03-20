%% Test that Erlang cover tool can compile any valid Erlang program

-module(cover_eqc).

-include_lib("eqc/include/eqc.hrl").
-compile(export_all).

-define(TEST_MODULE, myerlangprog).

%% Cover compile cover with eqc_cover
%% Tricky, since cover.erl has its own parse transform

compile() ->
  {Path,_} = filename:find_src(cover),
  io:format("Cover is found at ~p\n",[Path]),
  {ok, _BytesCopied} = file:copy(Path ++ ".erl", "cover.erl"),
  io:format("Directory contains: ~p\n",[file:list_dir(".")]).

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
