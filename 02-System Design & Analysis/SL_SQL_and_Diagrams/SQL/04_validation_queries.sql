-- Read-only verification queries: return diagnostics, not evidence of a completed DB test.
-- Run after 01, 02 and the approved EDA seed. Empty-schema counts alone DO NOT prove behavior.
SELECT COUNT(*) AS total_categories, COUNT(*) FILTER (WHERE is_active) AS active_categories, (COUNT(*) = 5 AND COUNT(*) FILTER (WHERE is_active) = 5) AS exactly_five_categories_ready FROM supported_category;
SELECT COUNT(*) AS duplicate_category_codes FROM (SELECT category_code FROM supported_category GROUP BY category_code HAVING COUNT(*) > 1) d;
SELECT COUNT(*) AS orphan_runs FROM analysis_run a LEFT JOIN product_listing l ON l.listing_id=a.listing_id WHERE l.listing_id IS NULL;
SELECT COUNT(*) AS orphan_predictions FROM visual_prediction p LEFT JOIN analysis_run a ON a.analysis_run_id=p.analysis_run_id WHERE a.analysis_run_id IS NULL;
SELECT COUNT(*) AS orphan_claims FROM text_claim c LEFT JOIN analysis_run a ON a.analysis_run_id=c.analysis_run_id WHERE a.analysis_run_id IS NULL;
SELECT COUNT(*) AS orphan_findings FROM analysis_finding f LEFT JOIN analysis_run a ON a.analysis_run_id=f.analysis_run_id WHERE a.analysis_run_id IS NULL;
SELECT COUNT(*) AS orphan_suggestions FROM suggested_correction s LEFT JOIN analysis_run a ON a.analysis_run_id=s.analysis_run_id WHERE a.analysis_run_id IS NULL;
SELECT COUNT(*) AS orphan_decisions FROM seller_decision d LEFT JOIN suggested_correction s ON s.suggestion_id=d.suggestion_id WHERE s.suggestion_id IS NULL;
SELECT COUNT(*) AS invalid_visual_confidence FROM visual_prediction WHERE confidence NOT BETWEEN 0 AND 1 AND confidence IS NOT NULL;
SELECT COUNT(*) AS invalid_finding_confidence FROM analysis_finding WHERE confidence NOT BETWEEN 0 AND 1 AND confidence IS NOT NULL;
SELECT COUNT(*) AS invalid_score FROM analysis_run WHERE quality_score IS NOT NULL AND (quality_score < 0 OR quality_score > 100);
SELECT COUNT(*) AS invalid_prediction_category FROM visual_prediction p LEFT JOIN supported_category c ON p.predicted_category_code=c.category_code WHERE p.predicted_category_code IS NOT NULL AND (c.category_code IS NULL OR NOT c.is_active);
SELECT COUNT(*) AS duplicate_selected_predictions FROM (SELECT analysis_run_id, attribute FROM visual_prediction WHERE is_selected GROUP BY analysis_run_id, attribute HAVING COUNT(*) > 1) d;
SELECT COUNT(*) AS duplicate_findings FROM (SELECT analysis_run_id, reason_code, attribute_scope FROM analysis_finding GROUP BY analysis_run_id, reason_code, attribute_scope HAVING COUNT(*) > 1) d;
SELECT COUNT(*) AS listings_with_multiple_runs FROM (SELECT listing_id FROM analysis_run GROUP BY listing_id HAVING COUNT(*) > 1) x;
SELECT COUNT(*) AS analyses_with_multiple_findings FROM (SELECT analysis_run_id FROM analysis_finding GROUP BY analysis_run_id HAVING COUNT(*) > 1) x;
SELECT COUNT(*) AS decided_suggestions FROM seller_decision;
SELECT COUNT(*) AS suggestions_waiting_for_decision FROM suggested_correction s LEFT JOIN seller_decision d ON d.suggestion_id=s.suggestion_id WHERE d.decision_id IS NULL;
-- Latest result per listing; status rules Q-01/Q-02 belong to approved triage logic, not SQL.
WITH ranked AS (SELECT r.*, ROW_NUMBER() OVER (PARTITION BY listing_id ORDER BY created_at DESC, analysis_run_id DESC) rn FROM analysis_run r)
SELECT listing_id, analysis_run_id, queue_state, inconsistency_level, status FROM ranked WHERE rn=1 ORDER BY listing_id;
-- Optional queue filter for UC-13: latest completed/partial run only.
WITH ranked AS (SELECT r.*, ROW_NUMBER() OVER (PARTITION BY listing_id ORDER BY created_at DESC, analysis_run_id DESC) rn FROM analysis_run r WHERE status IN ('completed','partial'))
SELECT listing_id, analysis_run_id, queue_state FROM ranked WHERE rn=1 AND queue_state='needs_review' ORDER BY created_at DESC;
