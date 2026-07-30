# Synthesis Notes

ZEALS synthesis combines deterministic evidence from perturbation execution:

1. Profiles each perturbation with coverage, precision, and failure tendency.
2. Infers conservative capability terms from successful vs failing feature observations.
3. Extracts boundaries as minimal feature differences between success/failure pairs.
4. Ranks methods from profile evidence.
5. Produces a guarded fallback plan with explicit unresolved branch.

Plan shape currently uses:

- `sequence([...])`
- `fallback([...])`
- `verify(independent_verifier, method(PerturbationId))`
- `fail_with(unknown, reason(no_applicable_verified_method))`

Uncertainty is explicit through unresolved fallback and non-verified status handling.

