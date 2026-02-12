-- Rename 'KO' to 'FLAGGED' in moderation_history
UPDATE public.moderation_history 
SET final_decision = 'FLAGGED' 
WHERE final_decision = 'KO';

-- Update the comment on the table column if needed (informational)
COMMENT ON COLUMN public.moderation_history.final_decision IS '''OK'' or ''FLAGGED''';
