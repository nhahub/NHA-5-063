# SmartListing Copilot — Relational Schema

**Status:** Proposed logical/physical design; PostgreSQL assumed; category labels pending EDA.

## Relations and keys

**supported_category** (category_code [PK], display_name, is_active)

**product_listing** (listing_id [PK], image_ref, image_sha256, image_origin, dataset_product_id, title, description, seller_category, text_origin, created_at)

**analysis_run** (analysis_run_id [PK], listing_id [FK], status, queue_state, inconsistency_level, quality_score, image_width_px, image_height_px, is_blurred, brightness_status, cv_model_version, nlp_lexicon_version, ruleset_version, created_at, completed_at)

**visual_prediction** (prediction_id [PK], analysis_run_id [FK], attribute, model_source, prediction_state, predicted_category_code [FK], predicted_color, confidence, is_selected)

**text_claim** (claim_id [PK], analysis_run_id [FK], attribute, source_field, matched_text, canonical_value, script_route)

**analysis_finding** (finding_id [PK], analysis_run_id [FK], reason_code, attribute_scope, severity, confidence, visual_value, claimed_value, explanation)

**suggested_correction** (suggestion_id [PK], analysis_run_id [FK], suggested_title, suggested_description, change_explanation)

**seller_decision** (decision_id [PK], suggestion_id [FK], decision, final_title, final_description, decided_at)

## Referential relationships

- `analysis_run.listing_id` → `product_listing(listing_id)`; `ON DELETE RESTRICT`
- `visual_prediction.analysis_run_id` → `analysis_run(analysis_run_id)`; `ON DELETE CASCADE`
- `visual_prediction.predicted_category_code` → `supported_category(category_code)`; `ON DELETE RESTRICT`
- `text_claim.analysis_run_id` → `analysis_run(analysis_run_id)`; `ON DELETE CASCADE`
- `analysis_finding.analysis_run_id` → `analysis_run(analysis_run_id)`; `ON DELETE CASCADE`
- `suggested_correction.analysis_run_id` → `analysis_run(analysis_run_id)`; `ON DELETE CASCADE`
- `seller_decision.suggestion_id` → `suggested_correction(suggestion_id)`; `ON DELETE RESTRICT`

## Cardinality notes

- A `product_listing` has zero or many `analysis_run` records; each run belongs to exactly one listing.
- Each run can carry zero or many `visual_prediction`, `text_claim`, and `analysis_finding` rows.
- Each run has zero or one `suggested_correction`, and each suggestion has zero or one `seller_decision`.
- `supported_category` classifies zero or many selected/product-type predictions; each such typed prediction references exactly one valid category.
- No `User`, `ProductImage` multi-image table, or `ModelVersion` table: current scope does not authorize them.

## Integrity and access patterns

- One selected prediction per run/attribute uses a **partial unique index**. Category lookup is deliberately **unseeded** pending EDA.
- The review queue is a **query over the latest analysis run per listing**, not another table; see `SQL/04_validation_queries.sql`.
- The original listing is immutable by application policy. A chosen wording is stored in `seller_decision` only for Edit.
- Duplicate submitted images and multiple runs are permitted; the uniqueness rules target findings and decisions, not image reuse.
- Image contents, model weights, templates and vocabularies are stored outside SQL; only image pointers and model artifact identifiers appear here.
