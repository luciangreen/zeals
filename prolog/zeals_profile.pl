:- module(zeals_profile, [
    profile_perturbation/3,
    profile_all/3,
    infer_capability/3,
    infer_capabilities/3,
    capability_applies/2
]).

:- use_module(library(lists)).
:- use_module(zeals_registry).
:- use_module(zeals_case).
:- use_module(zeals_util).

profile_perturbation(PerturbationId, Results, Profile) :-
    include(result_for(PerturbationId), Results, PerturbationResults),
    length(PerturbationResults, Attempted),
    count_status(PerturbationResults, correct, Correct),
    count_status(PerturbationResults, incorrect, Incorrect),
    count_status(PerturbationResults, unsupported, Unsupported),
    count_status(PerturbationResults, timeout, Timeout),
    count_status(PerturbationResults, verification_failed, VerificationFailed),
    count_status(PerturbationResults, exception, Exception),
    count_status(PerturbationResults, partial, Partial),
    safe_ratio_or_zero(Attempted - Unsupported, Attempted, Coverage),
    safe_ratio_or_zero(Correct, Correct + Incorrect + VerificationFailed, VerifiedPrecision),
    safe_ratio_or_zero(Incorrect + VerificationFailed, Attempted, FalseApplicabilityRate),
    average_time(PerturbationResults, AverageTimeMs),
    Profile = profile{
        perturbation: PerturbationId,
        attempted: Attempted,
        correct: Correct,
        incorrect: Incorrect,
        partial: Partial,
        unsupported: Unsupported,
        timeout: Timeout,
        exception: Exception,
        verification_failed: VerificationFailed,
        coverage: Coverage,
        verified_precision: VerifiedPrecision,
        average_time_ms: AverageTimeMs,
        false_applicability_rate: FalseApplicabilityRate
    }.

profile_all(ProblemId, Results, Profiles) :-
    zeals_registry:perturbation_ids_for_problem(ProblemId, PerturbationIds),
    findall(
        Profile,
        (
            member(PerturbationId, PerturbationIds),
            profile_perturbation(PerturbationId, Results, Profile)
        ),
        Profiles
    ),
    zeals_registry:set_profiles(ProblemId, Profiles).

infer_capability(PerturbationId, Results, Capability) :-
    include(result_for(PerturbationId), Results, PerturbationResults),
    findall(Features, successful_result_features(PerturbationResults, Features), SuccessFeatures),
    findall(Features, failing_result_features(PerturbationResults, Features), FailureFeatures),
    intersection_features(SuccessFeatures, PositiveConditions),
    union_features(FailureFeatures, FailureUnion),
    subtract(FailureUnion, PositiveConditions, NegativeConditions),
    length(SuccessFeatures, SuccessCount),
    length(FailureFeatures, FailureCount),
    safe_ratio_or_zero(SuccessCount, SuccessCount + FailureCount, Confidence),
    Capability = capability(
        PerturbationId,
        PositiveConditions,
        NegativeConditions,
        Confidence,
        evidence(SuccessCount, FailureCount)
    ).

infer_capabilities(ProblemId, Results, Capabilities) :-
    zeals_registry:perturbation_ids_for_problem(ProblemId, PerturbationIds),
    findall(
        Capability,
        (
            member(PerturbationId, PerturbationIds),
            infer_capability(PerturbationId, Results, Capability)
        ),
        Capabilities
    ),
    zeals_registry:set_capabilities(ProblemId, Capabilities).

capability_applies(capability(_, PositiveConditions, NegativeConditions, _, _), Features) :-
    subset_terms(PositiveConditions, Features),
    \+ has_any_member(NegativeConditions, Features).

result_for(PerturbationId, result(PerturbationId, _, _, _, _, _, _, _)).

count_status(Results, Status, Count) :-
    include(has_status(Status), Results, Selected),
    length(Selected, Count).

has_status(Status, result(_, _, Status, _, _, _, _, _)).

average_time([], 0.0).
average_time(Results, AverageTimeMs) :-
    findall(
        TimeMs,
        (
            member(result(_, _, _, _, Cost, _, _, _), Results),
            get_dict(time_ms, Cost, TimeMs0),
            TimeMs is TimeMs0
        ),
        Times
    ),
    (   Times == []
    ->  AverageTimeMs = 0.0
    ;   sum_list(Times, Total),
        length(Times, Count),
        AverageTimeMs is Total / Count
    ).

safe_ratio_or_zero(Numerator, Denominator, Ratio) :-
    (   Denominator =:= 0
    ->  Ratio = 0.0
    ;   Ratio is Numerator / Denominator
    ).

successful_result_features(Results, Features) :-
    member(result(_, CaseId, correct, _, _, _, _, _), Results),
    result_case_features(CaseId, Features).

failing_result_features(Results, Features) :-
    member(result(_, CaseId, Status, _, _, _, _, _), Results),
    memberchk(Status, [incorrect, verification_failed, exception, timeout]),
    result_case_features(CaseId, Features).

result_case_features(CaseId, Features) :-
    zeals_case:get_case(CaseId, case(_, _, _Input, _ExpectedClass, _ExpectedOutput, Metadata)),
    (   metadata_value(Metadata, features, Features0)
    ->  ensure_list(Features0, Features)
    ;   Features = []
    ).

intersection_features([], []).
intersection_features([Head|Tail], Intersection) :-
    intersection_features(Tail, TailIntersection),
    include(member_in_all([Head|Tail]), Head, HeadIntersection),
    append(HeadIntersection, TailIntersection, Combined),
    sort(Combined, Intersection).

member_in_all(Lists, Feature) :-
    forall(member(List, Lists), memberchk(Feature, List)).

union_features(FeatureLists, Union) :-
    append(FeatureLists, Flat),
    sort(Flat, Union).

subset_terms([], _).
subset_terms([Item|Rest], List) :-
    memberchk(Item, List),
    subset_terms(Rest, List).

has_any_member([Item|_], List) :-
    memberchk(Item, List),
    !.
has_any_member([_|Rest], List) :-
    has_any_member(Rest, List).
