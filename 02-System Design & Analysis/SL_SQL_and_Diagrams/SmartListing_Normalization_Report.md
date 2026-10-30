# SmartListing Copilot — Normalization Report

**Member 2 | System Analysis & Design | 28 October 2026**  
**Status:** Proposed relational design; PostgreSQL engine and five categories awaiting approval.

## 1. Functional-dependency inventory

| Relation | Candidate / alternate keys | Functional dependencies and determinants |
|---|---|---|
| supported_category | `category_code` | `category_code → display_name, is_active` |
| product_listing | `listing_id` | `listing_id → image_ref, image_sha256, image_origin, dataset_product_id, title, description, seller_category, text_origin, created_at` |
| analysis_run | `analysis_run_id` | `analysis_run_id → listing_id, status, queue_state, inconsistency_level, quality_score, image quality fields, artifact identifiers, timestamps` |
| visual_prediction | `prediction_id`; also `(analysis_run_id, attribute, model_source)` | Either key determines selected predicted category/color, prediction state, confidence, and selected indicator. |
| text_claim | `claim_id` | `claim_id → analysis_run_id, attribute, source_field, matched_text, canonical_value, script_route` |
| analysis_finding | `finding_id`; also `(analysis_run_id, reason_code, attribute_scope)` | Each key determines severity, confidence, evidence values and explanation. |
| suggested_correction | `suggestion_id`; also `analysis_run_id` | Both keys determine suggested title/description and change explanation. |
| seller_decision | `decision_id`; also `suggestion_id` | Each key determines decision, final edited text (when relevant), and timestamp. |

`visual_prediction` additionally uses a *partial* uniqueness rule for `(analysis_run_id, attribute)` **only when** `is_selected=TRUE`; this filtered uniqueness is not a complete alternative candidate key for the entire relation.

## 2. First Normal Form (1NF)

The submitted fashion product may contain several NLP claims from title and description and several independently reportable mismatches. Embedding `claim_1`, `claim_2`, `finding_1`, `finding_2` or a comma-separated array of prediction results in a single listing row creates repeating groups. The design instead normalizes each observation to a separate `text_claim`, `visual_prediction` or `analysis_finding` record. The single image reference is a scalar field because the confirmed MVP accepts one image.

## 3. Second Normal Form (2NF)

Every relation has a single-attribute primary key (a code or surrogate). Non-key fields therefore cannot depend on a proper subset of a chosen PK. Alternate composite candidate keys need an additional check: in `visual_prediction`, neither `analysis_run_id` alone nor `attribute` or `model_source` alone determines the row's confidence or model prediction. In `analysis_finding`, a run alone cannot determine which reason code/severity applies, nor can a reason code alone specify a result. Hence no relevant partial dependencies are introduced by these uniqueness constraints.

## 4. Third Normal Form (3NF)

The design avoids storing descriptive attributes alongside foreign-key identifiers when a non-key determinant already exists:

- `predicted_category_code → supported_category.display_name`. **Do not copy `display_name` into `visual_prediction`**. This removes the transitive path `prediction_id → category_code → display_name`.
- `analysis_run_id → listing_id → submitted original title/description`. **Keep the original text only in `product_listing`**, not in every run.
- `decision_id → suggestion_id → suggested title/description`. **Keep suggestion text in `suggested_correction`**, while `seller_decision` only stores the decision and, on Edit, explicitly chosen final wording.
- Each listing's Review Queue is calculated from the latest usable `analysis_run`; no separate `review_queue` table duplicates that state and requires synchronization.

The editable `final_title/final_description` are **not** copies of proposed wording: they represent new seller-approved values conditional on an `edit` decision. The `analysis_run.queue_state`, `inconsistency_level`, and optional `quality_score` are persisted decision outputs of that particular run, not repeated references to mutable configuration. They could be recomputed from evidence under a fixed rule version, but keeping the outputs preserves historical review and is an explicitly documented persistence tradeoff.

## 5. Decomposition steps (illustrative)

1. **Unnormalized working record:** `(listing_id, image_ref, title, description, seller_category, analysis_run_id, prediction_* repeated, extracted_claims repeated, mismatch_warnings repeated, suggested_title, decision)`.
2. **1NF:** split repeating groups into one-row-per-observation child sets, preserving one immutable listing snapshot and one row per analysis attempt.
3. **2NF:** key predictions by `(run_id, attribute, model_source)` (or surrogate `prediction_id`), and findings by `(run_id, reason_code, scope)` (or surrogate `finding_id`). No dependent value is assigned on partial identifying information.
4. **3NF:** separate product-type vocabulary into `supported_category`, remove listing fields from analyses, and remove suggested text from decisions. Enforce these references using foreign keys.

## 6. Known limits

No approved model vocabulary/color family list was included, so normalized color is kept as a bounded text field and a separate Color lookup has deliberately not been invented. The five product classes remain unseeded until EDA. Semantic consistency between confidence, threshold, and classification accuracy must be verified by the CV and Scoring & Triage modules; relational normalization does not establish model correctness.

**Result:** The proposed relations satisfy 3NF under the documented key and functional-dependency assumptions. This is a design proof; actual deployment and performance validation remain pending.
