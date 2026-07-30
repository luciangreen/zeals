# ZEALS Synthesis Report

## Problem

`problem(sort_values,[unsorted_list],[sorted_list],[is_list],[sorting_zeals:sorted_permutation_invariant],[correctness],[feature_extractor(sorting_zeals:extract_features)])`

## Results

`[result(builtin_sort,sort_small_list,correct,[1,2,3],_12278{time_ms:0},1.0,[trace_event(started,_12304{case:sort_small_list,perturbation:builtin_sort}),trace_event(recognised,_12328{recogniser:sorting_zeals:recognise_list}),trace_event(precondition_checked,_12354{status:passed}),trace_event(postcondition_checked,_12374{status:passed}),trace_event(verification_passed,_12394{case:evidence(exact_match),global:evidence(invariants_passed)}),trace_event(completed,_12426{status:correct})],_12434{verification:passed}),result(builtin_sort,sort_small_list,correct,[1,2,3],_12484{time_ms:0},0.0,[trace_event(started,_12510{case:sort_small_list,perturbation:builtin_sort}),trace_event(recognised,_12534{recogniser:sorting_zeals:recognise_list}),trace_event(precondition_checked,_12560{status:passed}),trace_event(postcondition_checked,_12580{status:passed}),trace_event(verification_passed,_12600{case:evidence(exact_match),global:evidence(invariants_passed)}),trace_event(completed,_12632{status:correct})],_12640{verification:passed})]`

## Profiles

`[profile{attempted:2,average_time_ms:0,correct:2,coverage:1,exception:0,false_applicability_rate:0,incorrect:0,partial:0,perturbation:builtin_sort,timeout:0,unsupported:0,verification_failed:0,verified_precision:1}]`

## Capabilities

`[capability(builtin_sort,[contains_duplicates(false),length_class(short)],[],1,evidence(2,0))]`

## Failure boundaries

`[]`

## Components

`[component(recogniser(builtin_sort),builtin_sort,recogniser,(:)/2,contract(recogniser),[dependencies([]),conflicts([])]),component(solver(builtin_sort),builtin_sort,solver,(:)/2,contract(preconditions([])),[dependencies([]),conflicts([])]),component(verifier(builtin_sort),builtin_sort,verifier,(:)/2,contract(verifier),[dependencies([solver(builtin_sort)]),conflicts([])])]`

## Final synthesis plan

`sequence([analyse(problem(sort_values)),collect_components,fallback([verify(independent_verifier,method(builtin_sort)),fail_with(unknown,reason(no_applicable_verified_method))])])`
