# Architecture

ZEALS is split into cohesive modules:

- `zeals_registry.pl`: mutable registry state.
- `zeals_problem.pl`, `zeals_case.pl`, `zeals_perturbation.pl`: declaration normalization and validation.
- `zeals_generate.pl`: perturbation-dimension combination with compatibility rules and limits.
- `zeals_execute.pl`: guarded execution engine with resource limit handling and structured traces.
- `zeals_verify.pl`: problem-level and case-level verification plus candidate conflict handling.
- `zeals_profile.pl`: profile metrics and symbolic capability inference.
- `zeals_boundary.pl`: failure boundary extraction and validation.
- `zeals_component.pl`: reusable component extraction and dependency graph support.
- `zeals_synthesise.pl`: deterministic synthesis plan generation and validation.
- `zeals_emit.pl`: generated expert module writer and loadability check.
- `zeals_report.pl`: Markdown synthesis report.
- `zeals_cli.pl`, `zeals_repl.pl`: command and interactive interfaces.
- `zeals.pl`: public orchestrator predicates.

## Data flow

1. Register problem/cases/perturbations.
2. Generate perturbation instances from dimensions.
3. Execute perturbations over case matrix.
4. Profile and infer capabilities.
5. Detect failure boundaries.
6. Extract components and dependencies.
7. Build and validate synthesis plan.
8. Emit expert module and report.

Mutable registries are isolated in `zeals_registry.pl`; analysis and synthesis logic consume immutable result terms where possible.

