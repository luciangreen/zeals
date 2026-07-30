:- module(zeals_registry, [
    reset_registry/0,
    put_problem/3,
    remove_problem/1,
    problem/2,
    problem_ids/1,
    put_case/2,
    case/2,
    case_ids_for_problem/2,
    put_perturbation/3,
    perturbation/2,
    perturbation_ids_for_problem/2,
    set_dimensions/3,
    get_dimensions/2,
    add_setting_rule/7,
    setting_rules/3,
    set_generation_limit/2,
    generation_limit/2,
    set_feature_extractor/2,
    feature_extractor/2,
    put_method_contract/2,
    method_contract/2,
    set_results/2,
    results/2,
    set_profiles/2,
    profiles/2,
    set_capabilities/2,
    capabilities/2,
    set_boundaries/2,
    boundaries/2,
    set_components/2,
    components/2,
    set_plan/2,
    plan/2
]).

:- dynamic problem_store/2.
:- dynamic case_store/2.
:- dynamic perturbation_store/2.
:- dynamic dimensions_store/2.
:- dynamic setting_rule_store/7.
:- dynamic generation_limit_store/2.
:- dynamic feature_extractor_store/2.
:- dynamic method_contract_store/2.
:- dynamic results_store/2.
:- dynamic profiles_store/2.
:- dynamic capabilities_store/2.
:- dynamic boundaries_store/2.
:- dynamic components_store/2.
:- dynamic plan_store/2.

reset_registry :-
    retractall(problem_store(_, _)),
    retractall(case_store(_, _)),
    retractall(perturbation_store(_, _)),
    retractall(dimensions_store(_, _)),
    retractall(setting_rule_store(_, _, _, _, _, _, _)),
    retractall(generation_limit_store(_, _)),
    retractall(feature_extractor_store(_, _)),
    retractall(method_contract_store(_, _)),
    retractall(results_store(_, _)),
    retractall(profiles_store(_, _)),
    retractall(capabilities_store(_, _)),
    retractall(boundaries_store(_, _)),
    retractall(components_store(_, _)),
    retractall(plan_store(_, _)).

put_problem(Id, Problem, Replace) :-
    (   problem_store(Id, _),
        Replace \== true
    ->  fail
    ;   retractall(problem_store(Id, _)),
        assertz(problem_store(Id, Problem))
    ).

remove_problem(Id) :-
    retractall(problem_store(Id, _)),
    retractall(case_store(_, case(_, Id, _, _, _, _))),
    retractall(perturbation_store(_, perturbation(_, Id, _, _, _, _, _, _))),
    retractall(dimensions_store(Id, _)),
    retractall(setting_rule_store(Id, _, _, _, _, _, _)),
    retractall(generation_limit_store(Id, _)),
    retractall(feature_extractor_store(Id, _)),
    retractall(results_store(Id, _)),
    retractall(profiles_store(Id, _)),
    retractall(capabilities_store(Id, _)),
    retractall(boundaries_store(Id, _)),
    retractall(components_store(Id, _)),
    retractall(plan_store(Id, _)).

problem(Id, Problem) :-
    problem_store(Id, Problem).

problem_ids(Ids) :-
    findall(Id, problem_store(Id, _), Raw),
    sort(Raw, Ids).

put_case(Id, Case) :-
    retractall(case_store(Id, _)),
    assertz(case_store(Id, Case)).

case(Id, Case) :-
    case_store(Id, Case).

case_ids_for_problem(ProblemId, CaseIds) :-
    findall(
        CaseId,
        case_store(CaseId, case(CaseId, ProblemId, _, _, _, _)),
        Raw
    ),
    sort(Raw, CaseIds).

put_perturbation(Id, Perturbation, Replace) :-
    (   perturbation_store(Id, _),
        Replace \== true
    ->  fail
    ;   retractall(perturbation_store(Id, _)),
        assertz(perturbation_store(Id, Perturbation))
    ).

perturbation(Id, Perturbation) :-
    perturbation_store(Id, Perturbation).

perturbation_ids_for_problem(ProblemId, PerturbationIds) :-
    findall(
        PerturbationId,
        perturbation_store(
            PerturbationId,
            perturbation(PerturbationId, ProblemId, _, _, _, _, _, _)
        ),
        Raw
    ),
    sort(Raw, PerturbationIds).

set_dimensions(ProblemId, Dimensions, Replace) :-
    (   dimensions_store(ProblemId, _),
        Replace \== true
    ->  fail
    ;   retractall(dimensions_store(ProblemId, _)),
        assertz(dimensions_store(ProblemId, Dimensions))
    ).

get_dimensions(ProblemId, Dimensions) :-
    dimensions_store(ProblemId, Dimensions).

add_setting_rule(ProblemId, Kind, DimensionA, ValueA, DimensionB, ValueB, Replace) :-
    (   Replace == true
    ->  retractall(setting_rule_store(ProblemId, Kind, DimensionA, ValueA, DimensionB, ValueB, _))
    ;   true
    ),
    assertz(setting_rule_store(ProblemId, Kind, DimensionA, ValueA, DimensionB, ValueB, true)).

setting_rules(ProblemId, Kind, Rules) :-
    findall(
        rule(DimensionA, ValueA, DimensionB, ValueB),
        setting_rule_store(ProblemId, Kind, DimensionA, ValueA, DimensionB, ValueB, _),
        Rules
    ).

set_generation_limit(ProblemId, Limit) :-
    retractall(generation_limit_store(ProblemId, _)),
    assertz(generation_limit_store(ProblemId, Limit)).

generation_limit(ProblemId, Limit) :-
    generation_limit_store(ProblemId, Limit).

set_feature_extractor(ProblemId, FeatureExtractor) :-
    retractall(feature_extractor_store(ProblemId, _)),
    assertz(feature_extractor_store(ProblemId, FeatureExtractor)).

feature_extractor(ProblemId, FeatureExtractor) :-
    feature_extractor_store(ProblemId, FeatureExtractor).

put_method_contract(MethodId, MethodContract) :-
    retractall(method_contract_store(MethodId, _)),
    assertz(method_contract_store(MethodId, MethodContract)).

method_contract(MethodId, MethodContract) :-
    method_contract_store(MethodId, MethodContract).

set_results(ProblemId, Results) :-
    retractall(results_store(ProblemId, _)),
    assertz(results_store(ProblemId, Results)).

results(ProblemId, Results) :-
    results_store(ProblemId, Results).

set_profiles(ProblemId, Profiles) :-
    retractall(profiles_store(ProblemId, _)),
    assertz(profiles_store(ProblemId, Profiles)).

profiles(ProblemId, Profiles) :-
    profiles_store(ProblemId, Profiles).

set_capabilities(ProblemId, Capabilities) :-
    retractall(capabilities_store(ProblemId, _)),
    assertz(capabilities_store(ProblemId, Capabilities)).

capabilities(ProblemId, Capabilities) :-
    capabilities_store(ProblemId, Capabilities).

set_boundaries(ProblemId, Boundaries) :-
    retractall(boundaries_store(ProblemId, _)),
    assertz(boundaries_store(ProblemId, Boundaries)).

boundaries(ProblemId, Boundaries) :-
    boundaries_store(ProblemId, Boundaries).

set_components(ProblemId, Components) :-
    retractall(components_store(ProblemId, _)),
    assertz(components_store(ProblemId, Components)).

components(ProblemId, Components) :-
    components_store(ProblemId, Components).

set_plan(ProblemId, Plan) :-
    retractall(plan_store(ProblemId, _)),
    assertz(plan_store(ProblemId, Plan)).

plan(ProblemId, Plan) :-
    plan_store(ProblemId, Plan).

