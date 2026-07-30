:- begin_tests(execution).

:- use_module('../prolog/zeals').
:- use_module('../prolog/zeals_execute').
:- use_module(test_support).

test(correct_execution) :-
    test_support:setup_base_registry,
    zeals_execute:execute_perturbation(square_solver, case_ok, Result),
    Result = result(square_solver, case_ok, correct, 4, _, _, Trace, _),
    Trace \== [].

test(verification_failure) :-
    test_support:setup_base_registry,
    zeals_execute:execute_perturbation(square_solver, case_fail, Result),
    Result = result(square_solver, case_fail, verification_failed, _, _, _, _, _).

test(unsupported_case) :-
    test_support:setup_base_registry,
    zeals_execute:execute_perturbation(unsupported_guard, case_unsupported, Result),
    Result = result(unsupported_guard, case_unsupported, unsupported, _, _, _, _, _).

:- end_tests(execution).

