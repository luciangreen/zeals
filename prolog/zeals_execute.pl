:- module(zeals_execute, [
    execute_perturbation/3,
    execute_perturbation/4,
    execute_all/2,
    execute_matrix/3,
    recogniser_always/1,
    generated_executor/3
]).

:- use_module(library(lists)).
:- use_module(library(option)).
:- use_module(zeals_registry).
:- use_module(zeals_case).
:- use_module(zeals_perturbation).
:- use_module(zeals_verify).
:- use_module(zeals_util).

execute_perturbation(PerturbationId, CaseId, Result) :-
    execute_perturbation(PerturbationId, CaseId, [], Result).

execute_perturbation(PerturbationId, CaseId, Options, Result) :-
    zeals_perturbation:get_perturbation(
        PerturbationId,
        perturbation(PerturbationId, ProblemId, _Restrictions, _Assumptions, _Representation, MethodId, _Objectives, _)
    ),
    zeals_case:get_case(CaseId, Case),
    Case = case(CaseId, ProblemId, Input, _ExpectedClass, _ExpectedOutput, _Metadata),
    zeals_perturbation:method_contract(
        MethodId,
        Recogniser,
        Preconditions,
        Executor,
        Postconditions,
        _FailureModes,
        _Verifier
    ),
    option(timeout_seconds(TimeoutSeconds), Options, 5),
    option_bool(collect_trace, Options, true, CollectTrace),
    option_bool(verify, Options, true, Verify),
    BaseTrace = [trace_event(started, _{perturbation: PerturbationId, case: CaseId})],
    (   call_recogniser(Recogniser, Input)
    ->  TraceRecognised = [trace_event(recognised, _{recogniser: Recogniser})|BaseTrace],
        (   check_preconditions(Preconditions, Input)
        ->  TracePreconditions = [trace_event(precondition_checked, _{status: passed})|TraceRecognised],
            execute_with_limits(Executor, Input, TimeoutSeconds, ExecutionOutcome),
            process_execution_outcome(
                PerturbationId,
                ExecutionOutcome,
                ProblemId,
                Case,
                Verify,
                Postconditions,
                TracePreconditions,
                CollectTrace,
                Result
            )
        ;   finalize_result(
                PerturbationId,
                CaseId,
                unsupported,
                unsupported(preconditions_not_met),
                _{time_ms: 0},
                0.0,
                [trace_event(precondition_checked, _{status: failed})|TraceRecognised],
                _{reason: preconditions_not_met},
                CollectTrace,
                Result
            )
        )
    ;   finalize_result(
            PerturbationId,
            CaseId,
            unsupported,
            unsupported(not_recognised),
            _{time_ms: 0},
            0.0,
            [trace_event(recognised, _{status: failed})|BaseTrace],
            _{reason: not_recognised},
            CollectTrace,
            Result
        )
    ).

execute_all(ProblemId, Results) :-
    zeals_registry:perturbation_ids_for_problem(ProblemId, PerturbationIds),
    zeals_registry:case_ids_for_problem(ProblemId, CaseIds),
    execute_matrix(PerturbationIds, CaseIds, Results),
    zeals_registry:set_results(ProblemId, Results).

execute_matrix(PerturbationIds, CaseIds, Results) :-
    findall(
        Result,
        (
            member(PerturbationId, PerturbationIds),
            member(CaseId, CaseIds),
            execute_perturbation(PerturbationId, CaseId, Result)
        ),
        Results
    ).

recogniser_always(_Input).

generated_executor(Settings, Input, generated(_{settings: Settings, input: Input})).

call_recogniser(Recogniser, Input) :-
    callable_with_args(Recogniser, [Input]).

check_preconditions([], _Input).
check_preconditions([Precondition|Rest], Input) :-
    callable_with_args(Precondition, [Input]),
    check_preconditions(Rest, Input).

execute_with_limits(Executor, Input, TimeoutSeconds, Outcome) :-
    statistics(walltime, [StartMs, _]),
    catch(
        call_with_time_limit(
            TimeoutSeconds,
            callable_with_args(Executor, [Input, Output])
        ),
        Error,
        CaughtError = Error
    ),
    statistics(walltime, [EndMs, _]),
    TimeMs is EndMs - StartMs,
    (   var(CaughtError)
    ->  (   nonvar(Output)
        ->  Outcome = execution(Output, TimeMs)
        ;   Outcome = exception(executor_failed)
        )
    ;   CaughtError == time_limit_exceeded
    ->  Outcome = timeout
    ;   Outcome = exception(CaughtError)
    ).

process_execution_outcome(
    PerturbationId,
    execution(Output, TimeMs),
    ProblemId,
    Case,
    Verify,
    Postconditions,
    TraceIn,
    CollectTrace,
    Result
) :-
    Case = case(CaseId, _, _, _, _, _),
    (   check_postconditions(Postconditions, Output)
    ->  TracePost = [trace_event(postcondition_checked, _{status: passed})|TraceIn],
        apply_verification(Verify, ProblemId, Case, Output, _Verification, TracePost, TraceOut, Status, Diagnostics),
        confidence_for_status(Status, Confidence),
        finalize_result(
            PerturbationId,
            CaseId,
            Status,
            Output,
            _{time_ms: TimeMs},
            Confidence,
            TraceOut,
            Diagnostics,
            CollectTrace,
            Result
        )
    ;   finalize_result(
            PerturbationId,
            CaseId,
            verification_failed,
            Output,
            _{time_ms: TimeMs},
            0.0,
            [trace_event(postcondition_checked, _{status: failed})|TraceIn],
            _{reason: postcondition_failed},
            CollectTrace,
            Result
        )
    ).
process_execution_outcome(PerturbationId, timeout, _ProblemId, case(CaseId, _, _, _, _, _), _Verify, _Postconditions, TraceIn, CollectTrace, Result) :-
    finalize_result(
        PerturbationId,
        CaseId,
        timeout,
        timeout,
        _{time_ms: 0},
        0.0,
        [trace_event(exception, _{reason: timeout})|TraceIn],
        _{reason: timeout},
        CollectTrace,
        Result
    ).
process_execution_outcome(PerturbationId, exception(Error), _ProblemId, case(CaseId, _, _, _, _, _), _Verify, _Postconditions, TraceIn, CollectTrace, Result) :-
    finalize_result(
        PerturbationId,
        CaseId,
        exception,
        exception(Error),
        _{time_ms: 0},
        0.0,
        [trace_event(exception, _{error: Error})|TraceIn],
        _{reason: exception, error: Error},
        CollectTrace,
        Result
    ).

check_postconditions([], _Output).
check_postconditions([Postcondition|Rest], Output) :-
    callable_with_args(Postcondition, [Output]),
    check_postconditions(Rest, Output).

apply_verification(false, _ProblemId, _Case, _Output, skipped, Trace, [trace_event(verification_started, _{status: skipped})|Trace], correct, _{verification: skipped}).
apply_verification(true, ProblemId, Case, Output, Verification, TraceIn, TraceOut, Status, Diagnostics) :-
    Case = case(_, _, Input, _, _, _),
    zeals_verify:verify_candidate(ProblemId, Input, Output, GlobalVerification),
    zeals_verify:verify_against_case(Case, Output, CaseVerification),
    combine_verification(GlobalVerification, CaseVerification, Verification),
    verification_status(Verification, Status, Diagnostics),
    trace_from_verification(Verification, TraceIn, TraceOut).

combine_verification(verified(EvidenceA), verified(EvidenceB), verified(_{global: EvidenceA, case: EvidenceB})).
combine_verification(failed(Reason, Evidence), _CaseVerification, failed(Reason, Evidence)).
combine_verification(_GlobalVerification, failed(Reason, Evidence), failed(Reason, Evidence)).
combine_verification(unknown(Reason), _CaseVerification, unknown(Reason)).
combine_verification(_GlobalVerification, unknown(Reason), unknown(Reason)).
combine_verification(unsupported(Reason), _CaseVerification, unsupported(Reason)).
combine_verification(_GlobalVerification, unsupported(Reason), unsupported(Reason)).

verification_status(verified(_), correct, _{verification: passed}).
verification_status(failed(Reason, Evidence), verification_failed, _{verification: failed, reason: Reason, evidence: Evidence}).
verification_status(unknown(Reason), partial, _{verification: unknown, reason: Reason}).
verification_status(unsupported(Reason), unsupported, _{verification: unsupported, reason: Reason}).

trace_from_verification(verified(Evidence), TraceIn, [trace_event(verification_passed, Evidence)|TraceIn]).
trace_from_verification(failed(Reason, Evidence), TraceIn, [trace_event(verification_failed, _{reason: Reason, evidence: Evidence})|TraceIn]).
trace_from_verification(unknown(Reason), TraceIn, [trace_event(verification_failed, _{reason: Reason})|TraceIn]).
trace_from_verification(unsupported(Reason), TraceIn, [trace_event(verification_failed, _{reason: Reason})|TraceIn]).

confidence_for_status(correct, 1.0).
confidence_for_status(partial, 0.5).
confidence_for_status(_, 0.0).

finalize_result(
    PerturbationIdIn,
    CaseId,
    RawStatus,
    Output,
    Cost,
    Confidence,
    TraceIn,
    Diagnostics,
    CollectTrace,
    result(PerturbationId, CaseId, Status, Output, Cost, Confidence, TraceOut, Diagnostics)
) :-
    (   var(PerturbationIdIn)
    ->  PerturbationId = unknown_perturbation
    ;   PerturbationId = PerturbationIdIn
    ),
    normalise_status(RawStatus, Status),
    reverse(TraceIn, OrderedTrace),
    append(OrderedTrace, [trace_event(completed, _{status: Status})], FullTrace),
    (   CollectTrace == true
    ->  TraceOut = FullTrace
    ;   TraceOut = []
    ).
