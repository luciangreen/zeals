# ZEALS Synthesis Report

## Problem

`problem(classify_parity,[integer_value],[parity_class],[integer],[classification_zeals:valid_parity_output],[correctness],[])`

## Results

`[result(modulo_classifier,parity_two,correct,even,_11854{time_ms:1},1.0,[trace_event(started,_11880{case:parity_two,perturbation:modulo_classifier}),trace_event(recognised,_11904{recogniser:classification_zeals:recognise_integer}),trace_event(precondition_checked,_11930{status:passed}),trace_event(postcondition_checked,_11950{status:passed}),trace_event(verification_passed,_11970{case:evidence(exact_match),global:evidence(invariants_passed)}),trace_event(completed,_12002{status:correct})],_12010{verification:passed}),result(modulo_classifier,parity_two,correct,even,_12042{time_ms:1},0.0,[trace_event(started,_12068{case:parity_two,perturbation:modulo_classifier}),trace_event(recognised,_12092{recogniser:classification_zeals:recognise_integer}),trace_event(precondition_checked,_12118{status:passed}),trace_event(postcondition_checked,_12138{status:passed}),trace_event(verification_passed,_12158{case:evidence(exact_match),global:evidence(invariants_passed)}),trace_event(completed,_12190{status:correct})],_12198{verification:passed})]`

## Profiles

`[profile{attempted:2,average_time_ms:1,correct:2,coverage:1,exception:0,false_applicability_rate:0,incorrect:0,partial:0,perturbation:modulo_classifier,timeout:0,unsupported:0,verification_failed:0,verified_precision:1}]`

## Capabilities

`[capability(modulo_classifier,[parity(even)],[],1,evidence(2,0))]`

## Failure boundaries

`[]`

## Components

`[component(recogniser(modulo_classifier),modulo_classifier,recogniser,(:)/2,contract(recogniser),[dependencies([]),conflicts([])]),component(solver(modulo_classifier),modulo_classifier,solver,(:)/2,contract(preconditions([])),[dependencies([]),conflicts([])]),component(verifier(modulo_classifier),modulo_classifier,verifier,(:)/2,contract(verifier),[dependencies([solver(modulo_classifier)]),conflicts([])])]`

## Final synthesis plan

`sequence([analyse(problem(classify_parity)),collect_components,fallback([verify(independent_verifier,method(modulo_classifier)),fail_with(unknown,reason(no_applicable_verified_method))])])`
