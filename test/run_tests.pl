:- initialization(main, main).

main :-
    consult('test/test_problem.pl'),
    consult('test/test_generation.pl'),
    consult('test/test_execution.pl'),
    consult('test/test_profile.pl'),
    consult('test/test_boundary.pl'),
    consult('test/test_components.pl'),
    consult('test/test_synthesis.pl'),
    consult('test/test_verification.pl'),
    consult('test/test_emission.pl'),
    consult('test/test_integration.pl'),
    run_tests,
    halt.

