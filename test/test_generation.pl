:- begin_tests(generation).

:- use_module('../prolog/zeals').
:- use_module('../prolog/zeals_generate', []).
:- use_module(test_support).

test(single_dimension_generation) :-
    test_support:setup_base_registry,
    zeals:perturbation_dimension(sample_problem, domain, [integers]),
    zeals_generate:generate_perturbations(sample_problem, [include_dimensions([domain])], Perturbations),
    length(Perturbations, 1).

test(multi_dimension_generation_and_limit) :-
    test_support:setup_base_registry,
    zeals_generate:generate_perturbations(sample_problem, Perturbations),
    length(Perturbations, Count),
    Count > 0.

test(incompatibility_rule_applied) :-
    test_support:setup_base_registry,
    zeals_generate:generate_perturbations(sample_problem, Perturbations),
    \+ (
        member(perturbation(_, _, _, _, settings(Settings), _, _, _), Perturbations),
        member(setting(method, simple_method), Settings),
        member(setting(approximation_level, approximate), Settings)
    ).

test(estimate_count) :-
    test_support:setup_base_registry,
    zeals_generate:estimate_perturbation_count(sample_problem, Count),
    Count >= 1.

:- end_tests(generation).
