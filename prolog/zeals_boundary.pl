:- module(zeals_boundary, [
    detect_failure_boundaries/3,
    minimal_feature_difference/3,
    validate_boundary/3
]).

:- use_module(library(lists)).
:- use_module(zeals_case).

detect_failure_boundaries(PerturbationId, Results, Boundaries) :-
    findall(
        Boundary,
        (
            member(result(PerturbationId, SuccessCaseId, correct, _, _, _, _, _), Results),
            member(result(PerturbationId, FailureCaseId, FailureStatus, _, _, _, _, _), Results),
            memberchk(FailureStatus, [incorrect, verification_failed, exception, timeout, unsupported]),
            SuccessCaseId \== FailureCaseId,
            case_features(SuccessCaseId, SuccessFeatures),
            case_features(FailureCaseId, FailureFeatures),
            minimal_feature_difference(SuccessFeatures, FailureFeatures, Difference),
            Difference \== [],
            Boundary = failure_boundary(
                PerturbationId,
                boundary_condition(Difference),
                success_case(SuccessCaseId),
                failure_case(FailureCaseId),
                0.5
            )
        ),
        RawBoundaries
    ),
    sort(RawBoundaries, Boundaries).

minimal_feature_difference(SuccessFeatures, FailureFeatures, Difference) :-
    subtract(FailureFeatures, SuccessFeatures, AddedInFailure),
    subtract(SuccessFeatures, FailureFeatures, MissingInFailure),
    append(AddedInFailure, MissingInFailure, RawDifference),
    sort(RawDifference, Difference).

validate_boundary(failure_boundary(PerturbationId, boundary_condition(Difference), _, _, _), Results, Validation) :-
    include(result_for(PerturbationId), Results, PerturbationResults),
    include(matches_boundary(Difference), PerturbationResults, Matching),
    length(Matching, MatchingCount),
    include(is_failing_result, Matching, Failing),
    length(Failing, FailingCount),
    ratio_or_zero(FailingCount, MatchingCount, Confidence),
    Validation = boundary_validation{
        matching_count: MatchingCount,
        failing_count: FailingCount,
        confidence: Confidence
    }.

result_for(PerturbationId, result(PerturbationId, _, _, _, _, _, _, _)).

matches_boundary(Difference, result(_, CaseId, _, _, _, _, _, _)) :-
    case_features(CaseId, Features),
    subset_features(Difference, Features).

subset_features([], _).
subset_features([Feature|Rest], Features) :-
    memberchk(Feature, Features),
    subset_features(Rest, Features).

is_failing_result(result(_, _, Status, _, _, _, _, _)) :-
    memberchk(Status, [incorrect, verification_failed, exception, timeout, unsupported]).

ratio_or_zero(_N, 0, 0.0) :-
    !.
ratio_or_zero(N, D, Ratio) :-
    Ratio is N / D.

case_features(CaseId, Features) :-
    zeals_case:get_case(CaseId, case(_, _, _, _, _, Metadata)),
    (   member(features(Features0), Metadata)
    ->  Features = Features0
    ;   Features = []
    ).
