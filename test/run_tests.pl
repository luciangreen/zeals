:- module(zeals_test_runner, [run_all_tests/0]).

run_all_tests :-
    load_files([
        'test/test_problem.pl',
        'test/test_generation.pl',
        'test/test_execution.pl',
        'test/test_profile.pl',
        'test/test_boundary.pl',
        'test/test_components.pl',
        'test/test_synthesis.pl',
        'test/test_verification.pl',
        'test/test_emission.pl',
        'test/test_integration.pl'
    ], [if(not_loaded)]),
    run_tests.

main :-
    (   run_all_tests
    ->  halt(0)
    ;   halt(1)
    ).

:- initialization(main, main).
