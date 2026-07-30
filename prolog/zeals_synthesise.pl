:- module(zeals_synthesise, [
    synthesise_expert/2,
    synthesise_expert/3,
    validate_synthesis_plan/3,
    rank_method/5
]).

:- use_module(library(lists)).
:- use_module(library(option)).
:- use_module(zeals_registry).
:- use_module(zeals_execute).
:- use_module(zeals_profile).
:- use_module(zeals_component).
:- use_module(zeals_util).

synthesise_expert(ProblemId, Plan) :-
    synthesise_expert(ProblemId, [], Plan).

synthesise_expert(ProblemId, _Options, Plan) :-
    ensure_profiles(ProblemId, Results, Profiles),
    sort_profiles_for_ranking(Profiles, RankedProfiles),
    build_ranked_method_nodes(RankedProfiles, MethodNodes),
    fallback_with_unresolved(MethodNodes, FallbackPlan),
    Plan = sequence([
        analyse(problem(ProblemId)),
        collect_components,
        FallbackPlan
    ]),
    validate_synthesis_plan(ProblemId, Plan, valid),
    zeals_registry:set_plan(ProblemId, Plan),
    zeals_profile:infer_capabilities(ProblemId, Results, Capabilities),
    zeals_registry:set_capabilities(ProblemId, Capabilities),
    zeals_component:extract_all_components(ProblemId, _Components).

validate_synthesis_plan(ProblemId, Plan, Validation) :-
    (   has_unresolved_fallback(Plan),
        uses_registered_methods(ProblemId, Plan)
    ->  Validation = valid
    ;   Validation = invalid(invalid_synthesis_plan)
    ).

rank_method(ProblemId, Features, MethodId, Score, Reasons) :-
    method_profile(ProblemId, MethodId, Profile),
    get_dict(verified_precision, Profile, Precision),
    get_dict(coverage, Profile, Coverage),
    get_dict(false_applicability_rate, Profile, FalseApplicability),
    Specificity is feature_specificity(Features),
    Score is Precision * 100 + Coverage * 10 + Specificity - FalseApplicability * 20,
    Reasons = [
        precision(Precision),
        coverage(Coverage),
        false_applicability(FalseApplicability),
        specificity(Specificity)
    ].

ensure_profiles(ProblemId, Results, Profiles) :-
    (   zeals_registry:results(ProblemId, ExistingResults)
    ->  Results = ExistingResults
    ;   zeals_execute:execute_all(ProblemId, Results)
    ),
    zeals_profile:profile_all(ProblemId, Results, Profiles).

sort_profiles_for_ranking(Profiles, RankedProfiles) :-
    map_list_to_pairs(profile_score, Profiles, Scored),
    keysort(Scored, Ascending),
    reverse(Ascending, Descending),
    pairs_values(Descending, RankedProfiles).

profile_score(Profile, Score) :-
    get_dict(verified_precision, Profile, Precision),
    get_dict(coverage, Profile, Coverage),
    get_dict(false_applicability_rate, Profile, FalseApplicability),
    Score is Precision * 100 + Coverage * 10 - FalseApplicability * 20.

build_ranked_method_nodes(Profiles, MethodNodes) :-
    findall(
        verify(independent_verifier, method(MethodId)),
        (
            member(Profile, Profiles),
            MethodId = Profile.perturbation
        ),
        MethodNodes
    ).

fallback_with_unresolved(MethodNodes, fallback(PlanNodes)) :-
    append(
        MethodNodes,
        [fail_with(unknown, reason(no_applicable_verified_method))],
        PlanNodes
    ).

has_unresolved_fallback(Term) :-
    sub_term(fail_with(unknown, _), Term).

uses_registered_methods(ProblemId, Plan) :-
    zeals_registry:perturbation_ids_for_problem(ProblemId, PerturbationIds),
    findall(MethodId, sub_term(method(MethodId), Plan), MethodIds),
    subset_ids(MethodIds, PerturbationIds).

subset_ids([], _).
subset_ids([Head|Tail], List) :-
    memberchk(Head, List),
    subset_ids(Tail, List).

method_profile(ProblemId, MethodId, Profile) :-
    zeals_registry:profiles(ProblemId, Profiles),
    member(Profile, Profiles),
    Profile.perturbation == MethodId.

feature_specificity(Features) :-
    length(Features, Count),
    Count.
