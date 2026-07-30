# ZEALS

ZEALS (Zoned Expert Algorithmic Layer Synthesis) is a SWI-Prolog framework that builds a guarded expert algorithm from simpler perturbation models. It registers problems and cases, executes perturbations, profiles behaviour, infers conservative capability hints, detects failure boundaries, extracts reusable components, synthesises a plan, emits runnable Prolog, and writes reports.

## Installation

1. Install SWI-Prolog (10.x or newer recommended).
2. Clone this repository.
3. Run tests:

```bash
swipl -q -s test/run_tests.pl
```

## Quick start

Load the maths example and run the workflow:

```prolog
?- [examples/maths_zeals].
?- zeals:zeals_generate(solve_equation).
?- zeals:zeals_execute(solve_equation).
?- zeals:zeals_profile(solve_equation).
?- zeals:zeals_boundaries(solve_equation).
?- zeals:zeals_synthesise(solve_equation).
?- zeals:zeals_emit(solve_equation, 'generated_maths_expert.pl').
?- [generated_maths_expert].
```

Run with matching input from registered cases:

```prolog
?- zeals:zeals_run(
       solve_equation,
       equation(add(multiply(number(2), variable(x)), number(3)), number(7)),
       Result
   ).
```

## Showcased example commands

```bash
swipl -q -s prolog/zeals_cli.pl -- validate examples/maths_zeals.pl
swipl -q -s prolog/zeals_cli.pl -- synthesise examples/maths_zeals.pl
swipl -q -s prolog/zeals_cli.pl -- report examples/maths_zeals.pl maths_report.md

swipl -q -s prolog/zeals_cli.pl -- validate examples/sorting_zeals.pl
swipl -q -s prolog/zeals_cli.pl -- synthesise examples/sorting_zeals.pl
swipl -q -s prolog/zeals_cli.pl -- report examples/sorting_zeals.pl sorting_report.md

swipl -q -s prolog/zeals_cli.pl -- validate examples/classification_zeals.pl
swipl -q -s prolog/zeals_cli.pl -- synthesise examples/classification_zeals.pl
swipl -q -s prolog/zeals_cli.pl -- report examples/classification_zeals.pl classification_report.md
```

## CLI

```bash
swipl -q -s prolog/zeals_cli.pl -- validate examples/maths_zeals.pl
swipl -q -s prolog/zeals_cli.pl -- synthesise examples/maths_zeals.pl
swipl -q -s prolog/zeals_cli.pl -- emit examples/maths_zeals.pl generated_maths_expert.pl
swipl -q -s prolog/zeals_cli.pl -- report examples/maths_zeals.pl zeals_report.md
swipl -q -s prolog/zeals_cli.pl -- test
```

## Project status

The first release implements staged ZEALS architecture with deterministic registries, perturbation generation constraints, guarded execution, verification hooks, profiling, boundary detection, component extraction, synthesis-plan generation, code emission, reports, CLI, REPL entrypoint, and integration tests.
