:- begin_tests(profile).

:- use_module('../prolog/zeals').
:- use_module('../prolog/zeals_execute').
:- use_module('../prolog/zeals_profile').
:- use_module(test_support).

test(profile_counts_and_metrics) :-
    test_support:setup_base_registry,
    zeals_execute:execute_all(sample_problem, Results),
    zeals_profile:profile_perturbation(square_solver, Results, Profile),
    Profile.attempted > 0,
    Profile.correct >= 1.

test(capability_inference) :-
    test_support:setup_base_registry,
    zeals_execute:execute_all(sample_problem, Results),
    zeals_profile:infer_capability(square_solver, Results, Capability),
    Capability = capability(square_solver, _, _, _, _).

:- end_tests(profile).

