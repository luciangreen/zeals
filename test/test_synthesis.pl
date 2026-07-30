:- begin_tests(synthesis).

:- use_module('../prolog/zeals').
:- use_module('../prolog/zeals_execute').
:- use_module('../prolog/zeals_synthesise').
:- use_module(test_support).

test(plan_contains_unresolved_fallback) :-
    test_support:setup_base_registry,
    zeals_execute:execute_all(sample_problem, _),
    zeals_synthesise:synthesise_expert(sample_problem, Plan),
    sub_term(fail_with(unknown, _), Plan).

test(plan_validation) :-
    test_support:setup_base_registry,
    zeals_execute:execute_all(sample_problem, _),
    zeals_synthesise:synthesise_expert(sample_problem, Plan),
    zeals_synthesise:validate_synthesis_plan(sample_problem, Plan, valid).

:- end_tests(synthesis).

