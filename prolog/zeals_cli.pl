:- module(zeals_cli, [main/0]).

:- use_module(zeals).

:- initialization(main, main).

main :-
    current_prolog_flag(argv, Argv),
    (   run_cli(Argv)
    ->  halt(0)
    ;   halt(1)
    ).

run_cli([validate, File]) :-
    zeals:zeals_load(File).
run_cli([generate, File]) :-
    zeals:zeals_load(File),
    zeals:zeals_problems([ProblemId|_]),
    zeals:zeals_generate(ProblemId).
run_cli([execute, File]) :-
    zeals:zeals_load(File),
    zeals:zeals_problems([ProblemId|_]),
    zeals:zeals_execute(ProblemId).
run_cli([profile, File]) :-
    zeals:zeals_load(File),
    zeals:zeals_problems([ProblemId|_]),
    zeals:zeals_execute(ProblemId),
    zeals:zeals_profile(ProblemId).
run_cli([boundaries, File]) :-
    zeals:zeals_load(File),
    zeals:zeals_problems([ProblemId|_]),
    zeals:zeals_execute(ProblemId),
    zeals:zeals_boundaries(ProblemId).
run_cli([components, File]) :-
    zeals:zeals_load(File),
    zeals:zeals_problems([ProblemId|_]),
    zeals:zeals_synthesise(ProblemId).
run_cli([synthesise, File]) :-
    zeals:zeals_load(File),
    zeals:zeals_problems([ProblemId|_]),
    zeals:zeals_synthesise(ProblemId).
run_cli([emit, File, Output]) :-
    zeals:zeals_load(File),
    zeals:zeals_problems([ProblemId|_]),
    zeals:zeals_execute(ProblemId),
    zeals:zeals_synthesise(ProblemId),
    zeals:zeals_emit(ProblemId, Output).
run_cli([report, File, Output]) :-
    zeals:zeals_load(File),
    zeals:zeals_problems([ProblemId|_]),
    zeals:zeals_execute(ProblemId),
    zeals:zeals_profile(ProblemId),
    zeals:zeals_boundaries(ProblemId),
    zeals:zeals_synthesise(ProblemId),
    zeals:zeals_report(ProblemId, Output).
run_cli([run, File, InputAtom]) :-
    zeals:zeals_load(File),
    zeals:zeals_problems([ProblemId|_]),
    term_to_atom(Input, InputAtom),
    zeals:zeals_run(ProblemId, Input, Result),
    writeln(Result).
run_cli([test]) :-
    consult('test/run_tests.pl'),
    run_tests,
    \+ current_prolog_flag(testing_failed, true).
run_cli(_) :-
    writeln('Usage: swipl -q -s prolog/zeals_cli.pl -- COMMAND ...'),
    fail.
