-- SmartListing Copilot indexes: safe to re-run; no destructive statements.
-- Indexes optimize the expected FastAPI queue and per-run detail queries.

-- At most one selected visual prediction per attribute and run.
CREATE UNIQUE INDEX IF NOT EXISTS uq_visual_selected_attribute ON visual_prediction (analysis_run_id, attribute) WHERE is_selected = TRUE;

-- Chronological submitted-listing retrieval.
CREATE INDEX IF NOT EXISTS idx_listing_created ON product_listing (created_at DESC) ;

-- Latest-run retrieval for each listing.
CREATE INDEX IF NOT EXISTS idx_run_listing_latest ON analysis_run (listing_id, created_at DESC, analysis_run_id DESC) ;

-- Filter recent analyses by Review Queue state.
CREATE INDEX IF NOT EXISTS idx_run_queue ON analysis_run (queue_state, created_at DESC) ;

-- Results-page finding retrieval and severity ordering.
CREATE INDEX IF NOT EXISTS idx_finding_run_severity ON analysis_finding (analysis_run_id, severity) ;

-- Efficient claims retrieval per run.
CREATE INDEX IF NOT EXISTS idx_claim_run_attribute ON text_claim (analysis_run_id, attribute) ;

-- Evidence lookup by run and attribute.
CREATE INDEX IF NOT EXISTS idx_prediction_run_attribute ON visual_prediction (analysis_run_id, attribute) ;
