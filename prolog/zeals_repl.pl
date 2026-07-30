:- module(zeals_repl, [
    zeals/0
]).

:- use_module(zeals).

zeals :-
    repeat,
    write('zeals> '),
    read(Command),
    (   Command == quit
    ->  !
    ;   handle_command(Command),
        fail
    ).

handle_command(load(File)) :- zeals:zeals_load(File), writeln(ok).
handle_command(problems) :- zeals:zeals_problems(Problems), writeln(Problems).
handle_command(generate(ProblemId)) :- zeals:zeals_generate(ProblemId), writeln(ok).
handle_command(execute(ProblemId)) :- zeals:zeals_execute(ProblemId), writeln(ok).
handle_command(profile(ProblemId)) :- zeals:zeals_profile(ProblemId), writeln(ok).
handle_command(boundaries(ProblemId)) :- zeals:zeals_boundaries(ProblemId), writeln(ok).
handle_command(synthesise(ProblemId)) :- zeals:zeals_synthesise(ProblemId), writeln(ok).
handle_command(show_plan(ProblemId)) :- zeals:get_plan(ProblemId, Plan), writeln(Plan).
handle_command(emit(ProblemId, File)) :- zeals:zeals_emit(ProblemId, File), writeln(ok).
handle_command(run(ProblemId, Input)) :- zeals:zeals_run(ProblemId, Input, Result), writeln(Result).
handle_command(report(ProblemId, File)) :- zeals:zeals_report(ProblemId, File), writeln(ok).
handle_command(unknown(Command)) :- format('Unknown command: ~q~n', [Command]).
handle_command(Command) :- format('Unknown command: ~q~n', [Command]).

