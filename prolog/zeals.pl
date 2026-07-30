:- module(zeals, [
    reset_zeals/0,
    zeals_load/1,
    zeals_problems/1,
    register_problem/1,
    register_problem/2,
    register_case/1,
    register_cases/1,
    register_perturbation/1,
    register_perturbation/2,
    register_perturbations/1,
    perturbation_dimension/3,
    generation_limit/2,
    compatible_setting/5,
    incompatible_setting/5,
    required_setting/5,
    zeals_generate/1,
    zeals_execute/1,
    zeals_profile/1,
    zeals_boundaries/1,
    zeals_synthesise/1,
    zeals_emit/2,
    zeals_report/2,
    zeals_run/3,
    get_plan/2,
    get_capabilities/2
]).

:- use_module(zeals_registry, [
    reset_registry/0,
    problem_ids/1,
    results/2,
    perturbation_ids_for_problem/2,
    case_ids_for_problem/2,
    set_boundaries/2,
    plan/2,
    capabilities/2
]).
:- use_module(zeals_problem, []).
:- use_module(zeals_case, []).
:- use_module(zeals_perturbation, []).
:- use_module(zeals_generate, []).
:- use_module(zeals_execute, []).
:- use_module(zeals_profile, []).
:- use_module(zeals_boundary, []).
:- use_module(zeals_component, []).
:- use_module(zeals_synthesise, []).
:- use_module(zeals_emit, []).
:- use_module(zeals_report, []).
:- use_module(zeals_verify, []).

reset_zeals :-
    zeals_registry:reset_registry.

zeals_load(File) :-
    reset_zeals,
    consult(File).

zeals_problems(ProblemIds) :-
    zeals_registry:problem_ids(ProblemIds).

register_problem(Problem) :-
    zeals_problem:register_problem(Problem).
register_problem(Problem, Options) :-
    zeals_problem:register_problem(Problem, Options).

register_case(Case) :-
    zeals_case:register_case(Case).
register_cases(Cases) :-
    zeals_case:register_cases(Cases).

register_perturbation(Perturbation) :-
    zeals_perturbation:register_perturbation(Perturbation).
register_perturbation(Perturbation, Options) :-
    zeals_perturbation:register_perturbation(Perturbation, Options).
register_perturbations(Perturbations) :-
    zeals_perturbation:register_perturbations(Perturbations).

perturbation_dimension(ProblemId, Dimension, Values) :-
    zeals_generate:perturbation_dimension(ProblemId, Dimension, Values).
generation_limit(ProblemId, Max) :-
    zeals_generate:generation_limit(ProblemId, Max).
compatible_setting(ProblemId, A, Av, B, Bv) :-
    zeals_generate:compatible_setting(ProblemId, A, Av, B, Bv).
incompatible_setting(ProblemId, A, Av, B, Bv) :-
    zeals_generate:incompatible_setting(ProblemId, A, Av, B, Bv).
required_setting(ProblemId, A, Av, B, Bv) :-
    zeals_generate:required_setting(ProblemId, A, Av, B, Bv).

zeals_generate(ProblemId) :-
    zeals_generate:generate_perturbations(ProblemId, _).

zeals_execute(ProblemId) :-
    zeals_execute:execute_all(ProblemId, _).

zeals_profile(ProblemId) :-
    zeals_registry:results(ProblemId, Results),
    zeals_profile:profile_all(ProblemId, Results, _Profiles),
    zeals_profile:infer_capabilities(ProblemId, Results, _Capabilities).

zeals_boundaries(ProblemId) :-
    zeals_registry:results(ProblemId, Results),
    zeals_registry:perturbation_ids_for_problem(ProblemId, PerturbationIds),
    findall(
        Boundary,
        (
            member(PerturbationId, PerturbationIds),
            zeals_boundary:detect_failure_boundaries(PerturbationId, Results, PerturbationBoundaries),
            member(Boundary, PerturbationBoundaries)
        ),
        Boundaries
    ),
    zeals_registry:set_boundaries(ProblemId, Boundaries).

zeals_synthesise(ProblemId) :-
    zeals_synthesise:synthesise_expert(ProblemId, _).

zeals_emit(ProblemId, File) :-
    zeals_registry:plan(ProblemId, Plan),
    atomic_list_concat([ProblemId, expert], '_', ModuleName),
    zeals_emit:emit_expert_module(
        ProblemId,
        Plan,
        File,
        [include_comments(true), module_name(ModuleName)]
    ).

zeals_report(ProblemId, File) :-
    zeals_report:write_synthesis_report(ProblemId, File, [format(markdown)]).

zeals_run(ProblemId, Input, Result) :-
    zeals_registry:perturbation_ids_for_problem(ProblemId, PerturbationIds),
    find_matching_case(ProblemId, Input, CaseId),
    run_ranked(PerturbationIds, CaseId, Result).

get_plan(ProblemId, Plan) :-
    zeals_registry:plan(ProblemId, Plan).

get_capabilities(ProblemId, Capabilities) :-
    (   zeals_registry:capabilities(ProblemId, Capabilities)
    ->  true
    ;   Capabilities = []
    ).

find_matching_case(ProblemId, Input, CaseId) :-
    zeals_registry:case_ids_for_problem(ProblemId, CaseIds),
    member(CaseId, CaseIds),
    zeals_case:get_case(CaseId, Case),
    Case = case(CaseId, ProblemId, Input, _, _, _),
    !.
find_matching_case(_ProblemId, _Input, unknown_input_case).

run_ranked([], _CaseId, unknown(reason(no_applicable_verified_method))).
run_ranked([PerturbationId|Rest], CaseId, Result) :-
    (   CaseId == unknown_input_case
    ->  Result = unknown(reason(no_matching_case))
    ;   zeals_execute:execute_perturbation(PerturbationId, CaseId, ExecutionResult),
        ExecutionResult = result(_, _, Status, Output, _, _, _, _),
        (   Status == correct
        ->  Result = accepted(Output, via(PerturbationId))
        ;   run_ranked(Rest, CaseId, Result)
        )
    ).
