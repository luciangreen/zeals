:- module(zeals_explain, [
    explain_execution/5,
    explain_capability/2,
    explain_boundary/2
]).

explain_execution(ProblemId, Input, Result, Trace, Explanation) :-
    Result = result(PerturbationId, _CaseId, Status, Output, _Cost, Confidence, _Trace, Diagnostics),
    Explanation = explanation{
        problem: ProblemId,
        input: Input,
        selected_method: PerturbationId,
        status: Status,
        output: Output,
        confidence: Confidence,
        diagnostics: Diagnostics,
        trace_summary: Trace
    }.

explain_capability(capability(PerturbationId, Positive, Negative, Confidence, Evidence), Explanation) :-
    Explanation = capability_explanation{
        perturbation: PerturbationId,
        positive_conditions: Positive,
        negative_conditions: Negative,
        confidence: Confidence,
        evidence: Evidence
    }.

explain_boundary(failure_boundary(PerturbationId, Boundary, SuccessEvidence, FailureEvidence, Confidence), Explanation) :-
    Explanation = boundary_explanation{
        perturbation: PerturbationId,
        boundary: Boundary,
        success_evidence: SuccessEvidence,
        failure_evidence: FailureEvidence,
        confidence: Confidence
    }.

