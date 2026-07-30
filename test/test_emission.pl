:- begin_tests(emission).

:- use_module('../prolog/zeals').
:- use_module('../prolog/zeals_execute').
:- use_module('../prolog/zeals_synthesise').
:- use_module(test_support).

test(emits_loadable_module) :-
    test_support:setup_base_registry,
    zeals_execute:execute_all(sample_problem, _),
    zeals_synthesise:synthesise_expert(sample_problem, _Plan),
    zeals:zeals_emit(sample_problem, 'test/generated_expert.pl'),
    consult('test/generated_expert.pl'),
    current_predicate(expert_solve/3).

:- end_tests(emission).

