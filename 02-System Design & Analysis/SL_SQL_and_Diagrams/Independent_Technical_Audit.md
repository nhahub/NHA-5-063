# SmartListing Copilot — Independent Database Package Review

**Review date:** 29 October 2026  
**Artifact scope:** `SmartListing_Database_FINAL.zip` (28-page PDF + SQL + dictionary + ERD + diagram source)

## Verified artifact inventory

- Original ZIP: **36 files**, passes CRC verification.
- Documentation: real editable DOCX, PDF with **28 pages**, main ERD on a landscape A4 page, seven supporting diagrams; source artifacts included.
- Database: **8 tables**, **64 columns**, **7 foreign keys**, and **7 index statements** including one partial unique index.
- Excel dictionary column inventory independently matched the canonical authority schema: **64/64 columns matched**, no missing/extra columns in its table/column listing.
- Requirements traceability CSV includes **FR-001 through FR-025** with the approved requirement statements. This checks coverage, not implementation acceptance.
- PostgreSQL has **not** been executed. Previous behavior tests used a translated SQLite in-memory schema, which is not dialect-equivalent evidence.

## Technical observation 01 — corrected test evidence

The original 140-test ledger incorrectly labeled a rejected row as proof of an unknown category foreign key. Its test used `model_source='dominant_color'` with `attribute='product_type'`, violating `ck_visual_prediction_08` before isolating the FK.

**Independent targeted retest, SQLite surrogate:** using `model_source='primary_cv'`, `attribute='product_type'`, and `predicted_category_code='made_up_class'`, the insert was rejected with `FOREIGN KEY constraint failed`. An independent invalid source/type test was rejected by `CHECK constraint failed: ck_visual_prediction_08`. The validation ledger was updated to represent this distinction.

**Impact:** The SQL constraint itself appears correctly defined, but the prior evidence row was invalid. This review is not a substitute for PostgreSQL testing.

## Technical observation 02 — image provenance policy pending

The SQL imposes `CHECK (image_origin = 'fashion_product_images_small')` and defaults all listing images to that origin. This accurately marks dataset test fixtures but could incorrectly attribute externally uploaded seller images to the dataset. The FRS says that a seller provides a fashion product image; it does not require every submitted image to have come from that dataset.

**Decision required:** If the deployed MVP permits uploads not drawn from the dataset, define a controlled `seller_upload` or equivalent provenance category and document the source/validation rules. Otherwise explicitly document that the prototype accepts only dataset-sourced image fixtures. **No scope-changing SQL edit was silently made.**

## Presentation upgrades suggested, not implemented in this audit

1. Add a generated TOC with page numbers (the existing document provides a section index without page numbers).
2. For defense/presentation use, make the main ERD available as a full-size separate PDF/SVG in addition to its landscape A4 page.

## Readiness conclusion

**Good academic design baseline, not a PostgreSQL-validated implementation.** The verified ZIP inventory resolves the earlier reviewer limitation (“PDF only”). Before treating the design as final: obtain the EDA-selected five categories, confirm the DB engine with the architecture lead, decide the image-provenance policy, reconcile the API payloads with Member 4, and execute the real DDL and negative tests in PostgreSQL.
