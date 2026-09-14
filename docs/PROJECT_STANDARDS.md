# Project Standards

This document defines shared organizational standards for the disassembly project. It complements `DISASSEMBLY_STANDARDS.md` by covering naming, assets, manifests, provenance, generated material, and repository boundaries.

## Naming

Use stable, descriptive names when verified; preserve useful original identifiers, addresses, banks, sections, and table indices; mark uncertain interpretations explicitly; and keep genuine version, region, language, and revision differences clearly scoped.

## Source and generated material

Prefer editable source and reproducible conversion steps over opaque derived files. Track generated files when they are useful evidence or human-reviewable project artifacts with documented origin. Keep disposable build output, caches, and scratch dumps outside version control. Retail or rebuilt ROM images are never repository artifacts.

## Assets

Retain provenance for graphics, sprites, text, maps, audio, scripts, tables, and other recovered content. Human-viewable PNGs should accompany sprite/graphics reconstruction when practical. Verify byte identity or cryptographic hashes before deduplicating, and preserve target-specific provenance when one representative file is shared.

## Manifests

Use stable identifiers and record verified target/release, region, language, revision, repository path, source location, size, hashes, generation method, verification level, shared usage, and notes as applicable. Unknown fields remain `null`, `TBD`, or `unknown`.

See `../manifests/README.md` and `../manifests/example.asset-manifest.json`.

## Provenance and verification

Meaningful claims should identify the target and reproducible evidence. Use **Unverified**, **Observed**, **Reconstructed**, and **Matched** as defined in `VERIFICATION.md`.

## Repository structure and reviewability

Preserve the repository's verified architecture instead of forcing a layout copied from another generation. Add directories only for real project material. Prefer small, coherent commits and asset batches with related documentation/manifests updated together when practical.
