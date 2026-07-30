:- begin_tests(boundary).

:- use_module('../prolog/zeals').
:- use_module('../prolog/zeals_execute').
:- use_module('../prolog/zeals_boundary').
:- use_module(test_support).

test(boundary_detection) :-
    test_support:setup_base_registry,
    zeals_execute:execute_all(sample_problem, Results),
    zeals_boundary:detect_failure_boundaries(square_solver, Results, Boundaries),
    is_list(Boundaries).

test(minimal_feature_difference) :-
    zeals_boundary:minimal_feature_difference([a, b], [b, c], Difference),
    Difference == [a, c].

:- end_tests(boundary).

