:- module(zeals_report, [
    write_synthesis_report/3
]).

:- use_module(library(option)).
:- use_module(zeals_registry).
:- use_module(zeals_problem).

write_synthesis_report(ProblemId, File, _Options) :-
    zeals_problem:get_problem(ProblemId, Problem),
    (zeals_registry:results(ProblemId, Results) -> true ; Results = []),
    (zeals_registry:profiles(ProblemId, Profiles) -> true ; Profiles = []),
    (zeals_registry:capabilities(ProblemId, Capabilities) -> true ; Capabilities = []),
    (zeals_registry:boundaries(ProblemId, Boundaries) -> true ; Boundaries = []),
    (zeals_registry:components(ProblemId, Components) -> true ; Components = []),
    (zeals_registry:plan(ProblemId, Plan) -> true ; Plan = none),
    open(File, write, Stream),
    format(Stream, '# ZEALS Synthesis Report~n~n', []),
    format(Stream, '## Problem~n~n`~q`~n~n', [Problem]),
    format(Stream, '## Results~n~n`~q`~n~n', [Results]),
    format(Stream, '## Profiles~n~n`~q`~n~n', [Profiles]),
    format(Stream, '## Capabilities~n~n`~q`~n~n', [Capabilities]),
    format(Stream, '## Failure boundaries~n~n`~q`~n~n', [Boundaries]),
    format(Stream, '## Components~n~n`~q`~n~n', [Components]),
    format(Stream, '## Final synthesis plan~n~n`~q`~n', [Plan]),
    close(Stream).

