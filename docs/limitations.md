# Limitations

1. Capability and boundary inference are evidence-based heuristics, not formal proofs.
2. Behaviour quality depends on registered case coverage.
3. Feature extraction quality can bias inferred regions and boundaries.
4. Generation uses finite dimension sets and can still grow quickly without curated limits.
5. Runtime currently targets reproducible sequential execution, not distributed scheduling.
6. Emitted modules delegate to ZEALS runtime and are not fully standalone.
7. Unsupported constructs are surfaced explicitly as unsupported/unknown results.
8. `zeals_run/3` matches registered cases exactly and tries methods in registry
   order; it does not yet dispatch arbitrary inputs from the synthesized plan.
9. Explanation helpers exist for execution, capability, and boundary data, but
   are not integrated into the `zeals_run/3` result.
10. CLI commands operate on the first problem declared in the input file.
