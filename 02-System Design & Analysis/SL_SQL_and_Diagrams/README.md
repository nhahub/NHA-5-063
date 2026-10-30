# SmartListing Copilot — Member 2 Database Design Package

**Project:** SmartListing Copilot – Multimodal Listing Quality Control for Fashion E-Commerce  
**Academic phase:** System Analysis & Design  
**Responsible member:** Member 2 — Database Design  
**Prepared:** 28 October 2026  
**Current approval status:** Proposed design; team/supervisor sign-off pending.

## Read this first

The updated **28-page visual-architecture Word specification (v1.1)** is `SmartListing_Database_Design_Specification.docx`; a matching rendered PDF is included. The **full ERD (Figure 1)** is `SmartListing_ERD.png`, with editable source `SmartListing_ERD.mmd`. **Seven additional diagrams (Figures 2–8)** are embedded as individual annotated design plates in chapter 24 and exported as editable `.dot` + `.svg` and high-resolution `.png` in `Diagrams/`. A full schema-grounded data dictionary is in `SmartListing_Data_Dictionary.xlsx` (three sheets: column definitions, schema overview and FR mapping). The normalization report, relational schema, exact FRS traceability CSV, SQL scripts and verification report are included alongside.

## Schema overview

Eight tables, 64 fields, seven foreign keys, seven indexes, and full structural mapping of the 25 Functional Requirements:

1. `supported_category` — exact five product-type values to be selected after EDA; **NOT SEEDED**.
2. `product_listing` — one immutable listing, one image file reference and original title/description.
3. `analysis_run` — independent repeatable attempt, image-quality summary and queue result.
4. `visual_prediction` — product-type/color evidence from primary CV, CLIP and dominant-color checks.
5. `text_claim` — extracted Product Type/Color claims from submitted text.
6. `analysis_finding` — explanatory reason code, severity and confidence.
7. `suggested_correction` — at most one proposed title/description per run; not automatically applied.
8. `seller_decision` — at most one explicit Accept/Edit/Ignore decision per suggestion.

**Main relationships:** Listing 1 → 0..* Runs; Run 1 → 0..* Predictions/Claims/Findings; Run 1 → 0..1 Suggestion; Suggestion 1 → 0..1 Decision. Category 0..1 ← prediction (only type predictions with a populated code require a supported category). A Review Queue is derived from the latest completed/partial run per listing, not stored in another table.

**Excluded by design:** User/account tables, multiple image tables, payments, pricing, return risk, model weights, automatic marketplace publishing and other out-of-scope capabilities.

## Files and purposes

| Artifact | Description |
|---|---|
| `SmartListing_Database_Design_Specification.docx` | Professional A4 academic specification, numbered sections, full ERD plus seven visual design plates, 25-FR traceability and data dictionary |
| `SmartListing_Database_Design_Specification.pdf` | Rendered visual-verification copy (28 pages, including a landscape ERD page and seven figure plates) |
| `SmartListing_ERD.png` | High-resolution crow's-foot-style relationship diagram |
| `SmartListing_ERD.mmd` | Editable Mermaid schema with all fields and relationships |
| `Diagrams/` | Seven high-resolution annotated design plates (Figures 2–8), each with editable DOT, vector SVG, PNG and diagram index |
| `SmartListing_Relational_Schema.md` | Relation signatures, keys, FKs, cardinalities and conventions |
| `SmartListing_Data_Dictionary.xlsx` | 64-column inventory and traceability (three formatted tabs) |
| `SmartListing_Normalization_Report.md` | Concrete dependencies and 1NF/2NF/3NF proof |
| `SmartListing_FR_Traceability_Matrix.csv` | Exact FRS statements and database mappings, machine-readable |
| `SQL/01_create_schema.sql` | Create eight PostgreSQL tables and constraints; rerunnable in fresh schema |
| `SQL/02_constraints_indexes.sql` | Seven purpose-documented indexes; rerunnable |
| `SQL/03_seed_reference_data.sql` | **Read-only seed placeholder:** approved five categories not supplied |
| `SQL/04_validation_queries.sql` | Read-only diagnostic queries and latest-run Queue example |
| `Validation_Report.md` | Detailed 140-check report, execution limits and PostgreSQL follow-up |

## Visual architecture edition (v1.1)

The updated 28-page document adds a dedicated **Visual Architecture Atlas (§24)**, with seven new plates: conceptual entities and cardinalities; processing/persistence boundary; evidence and run history; human-controlled Accept/Edit/Ignore gate; FK delete topology; 1NF→3NF design transformation; and the SQL-derived Review Queue. Each plate explains its evidence basis and scope, with editable sources in `Diagrams/`. The original canonical eight-table SQL, 64-column Data Dictionary, full Crow’s Foot ERD and FRS mapping are unchanged. Figure numbers 2–8 follow the original Figure 1.

## Running the PostgreSQL files

PostgreSQL was **not available** for actual execution in the document-generation environment. The schema uses PostgreSQL constructs and is intentionally unseeded for category labels. After PostgreSQL is agreed and installed, from a suitable local shell execute:

```bash
psql -X -v ON_ERROR_STOP=1 -d <your_database> -f SQL/01_create_schema.sql
psql -X -v ON_ERROR_STOP=1 -d <your_database> -f SQL/02_constraints_indexes.sql
psql -X -v ON_ERROR_STOP=1 -d <your_database> -f SQL/03_seed_reference_data.sql
psql -X -v ON_ERROR_STOP=1 -d <your_database> -f SQL/04_validation_queries.sql
```

**Before use with real application data:** approve and add exactly five EDA-derived category codes via a separate reviewed seed/migration; only then can valid product-type predictions reference them. The provided seed script deliberately inserts none. `CREATE TABLE/INDEX IF NOT EXISTS` is safe to rerun but **does not migrate existing schema changes**. For a changed schema use a versioned migration, not manual table recreation. The validation queries are read-only and empty-database zeros are not evidence of successful negative tests.

## Validation status

- **140/140 automated checks passed, 0 failed** on 28 October 2026. Includes schema/ERD/FR static checks and transient in-memory **SQLite behavioral-simulation** cases covering PK, FK, CHECK, unique selected predictions, history, multiple warnings and delete behavior.
- **PostgreSQL execution: NOT RUN.** The SQLite simulation used temporary fake fixture codes only in RAM, never in production seeds. It does not prove PostgreSQL dialect correctness or complete application workflow.
- DOCX rendered and visually inspected; 28-page PDF generated, with ERD on one landscape A4 page and seven annotated visual plates.
- Member 3 architecture remains a proposal, and no supervisor validation or actual model training is claimed.

## Open dependencies requiring team confirmation

- Approve PostgreSQL engine and storage choice with Member 3.
- Approve the five EDA-selected category names/codes, confidence thresholds and controlled color families.
- Resolve FRS Q-01/Q-02 (Medium-only and conflicting Review Queue flags).
- Resolve IN-01..IN-04 (empty title/description, image decode/type and category validation).
- Agree on original dataset-image-only provenance versus seller upload demo handling; source documents differ in emphasis.
- Confirm seller decision retention and edited-wording history policies.
- Finalize Member 1 UML, Member 4 API, Member 5 UI/UX and Member 6 test plan against this schema.
- Run the SQL and negative constraint tests on an actual local PostgreSQL database before claiming implementation validation.

## Delivery checklist

- [x] FRS FR-001…FR-025 exact statements reviewed and mapped.
- [x] Conceptual and logical schema, PK/FK relationships and 3NF rationale.
- [x] A4 Word specification plus matching PDF rendering.
- [x] ERD PNG + editable Mermaid source.
- [x] Seven additional labeled diagrams; each with SVG, PNG, and editable DOT sources, embedded within the Word/PDF and cross-referenced from core sections.
- [x] Data Dictionary XLSX generated from canonical schema.
- [x] Rerunnable creation/index SQL, non-fabricated seed stage and read-only diagnostics.
- [x] Static and SQLite-surrogate automated checks recorded accurately.
- [ ] Execute on real PostgreSQL (not available here).
- [ ] Approve exact five categories and seed data.
- [ ] Resolve pending team/academic decisions and obtain sign-off.

**No proprietary or personal user records are embedded in these outputs.**
