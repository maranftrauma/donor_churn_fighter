# Function to drop variables
drop_variables <- function(dataframe,variable){
  return(dataframe.variable <- NULL)
}

# Function to transform data types
data_type_transformation <- function(variable,datatype){
  if (datatype == 'factor') {
    variable <- as.factor(variable)
  } else if (datatype == 'numeric') {
    variable <- as.numeric(variable)
  }  
  else {
    variable <- as.character(variable)
  } 
  return(variable)
}

# Function to input missing data
input_missings <- function(variable,inputation) {
  if (inputation == 0) {
    variable[is.na(variable)] <- 0
  } else if (inputation == 9999){
    variable[is.na(variable)] <- 9999
  } else {
    next
  }
}

# Preprocess function
apply_preprocess <- function(dataframe){
  #drop variables
  dataframe[col_drop] <- lapply(dataframe[col_drop],drop_variables)
  # transform datatype - numeric
  dataframe[cols_numeric] <- lapply(dataframe[cols_numeric],data_type_transformation, datatype= 'numeric')
  # input missing values - 9999
  dataframe[cols_input_9999] <- lapply(dataframe[cols_input_9999],input_missings, inputation= 9999)
  # input missing values - 0
  dataframe[cols_input_0] <- lapply(dataframe[cols_input_0],input_missings, inputation= 0)
}

#Columns to change
  col_drop <- c( 'donor_id'
                 ,'donation_beginning_date' 
                 ,'donation_end_date' 
                 ,'donation_beginning_ym' 
                 ,'donation_end_ym' 
                 ,'donation_ip' 
                 ,'campaign_beginning' 
                 ,'campaign_end' 
                 ,'donor_update_date' 
                 ,'tags_religion'
                 ,'donation_last_payment_method_used')
  cols_numeric <- c('donor_version_last_update')
  cols_input_9999 <- c('payment_diff_days_approved_vs_rejected'
                       , 'donor_version_last_update'
                       , 'campaign_end_ym'
                       , 'payment_diff_days_median_approved_vs_rejected')
  cols_input_0 <- c('users_camp_q_users' 
                    , 'users_camp_q_login' 
                    , 'shares_camp_q_shares' 
                    , 'avg_rejected_day' 
                    , 'std_rejected_day' 
                    , 'median_rejected_day'
                    , 'median_pay_day'
                    , 'donation_risk_measure' 
                    , 'donor_version_q_updates' 
                    , 'ratio_q_approved' 
                    , 'ratio_q_rejected' 
                    , 'ratio_q_pending' 
                    , 'ratio_q_cancelled' 
                    , 'ratio_q_charged_back' 
                    , 'ratio_q_in_process' 
                    , 'ratio_q_refunded' 
                    , 'ratio_q_error_code_019' 
                    , 'ratio_q_error_code_034' 
                    , 'ratio_q_null' 
                    , 'ratio_q_error_code_040' 
                    , 'ratio_q_error_code_026' 
                    , 'ratio_q_error_code_022' 
                    , 'ratio_q_error_code_86' 
                    , 'ratio_q_error_code_56' 
                    , 'ratio_q_card_change' 
                    , 'ratio_q_error_code_51' 
                    , 'ratio_q_error_code_52' 
                    , 'ratio_q_error_code_91' 
                    , 'ratio_q_error_code_63' 
                    , 'ratio_q_error_code_55' 
                    , 'ratio_q_error_code_006' 
                    , 'ratio_q_error_code_024' 
                    , 'ratio_q_error_code_020' 
                    , 'ratio_q_error_code_54' 
                    , 'ratio_q_error_code_99' 
                    , 'ratio_q_error_code_96' 
                    , 'ratio_q_error_code_50' 
                    , 'ratio_q_error_code_021' 
                    , 'ratio_q_error_code_62' 
                    , 'ratio_q_error_code_66' 
                    , 'ratio_q_error_code_01' 
                    , 'ratio_q_error_code_11' 
                    , 'ratio_q_error_code_081' 
                    , 'ratio_q_error_code_074' 
                    , 'ratio_q_error_code_035' 
                    , 'ratio_q_error_code_15' 
                    , 'ratio_q_error_code_79' 
                    , 'ratio_q_error_code_109' 
                    , 'ratio_q_error_code_008' 
                    , 'ratio_q_error_code_007' 
                    , 'ratio_q_error_code_21' 
                    , 'ratio_q_error_code_041' 
                    , 'ratio_q_error_code_78' 
                    , 'ratio_q_error_code_61' 
                    , 'ratio_q_error_code_07' 
                    , 'ratio_q_error_code_08' 
                    , 'ratio_q_cc_rejected_other_reason' 
                    , 'ratio_q_accredited' 
                    , 'ratio_q_error_code_033' 
                    , 'ratio_q_cc_rejected_bad_filled_security_code' 
                    , 'ratio_q_error_code_60' 
                    , 'ratio_q_cc_rejected_high_risk' 
                    , 'ratio_q_cc_rejected_call_for_authorize' 
                    , 'ratio_q_error_code_064' 
                    , 'ratio_q_error_code_64' 
                    , 'ratio_q_error_code_14' 
                    , 'ratio_q_cc_rejected_insufficient_amount' 
                    , 'ratio_q_expired' 
                    , 'ratio_q_settled' 
                    , 'ratio_q_error_code_015' 
                    , 'ratio_q_cc_rejected_blacklist' 
                    , 'ratio_q_error_code_135' 
                    , 'ratio_q_pending_review_manual' 
                    , 'ratio_error_q_in_process' 
                    , 'ratio_q_cc_rejected_bad_filled_date' 
                    , 'ratio_q_cc_rejected_bad_filled_other' 
                    , 'ratio_error_q_refunded' 
                    , 'ratio_q_error_code_145' 
                    , 'ratio_q_error_code_85' 
                    , 'ratio_q_cc_rejected_invalid_installments' 
                    , 'avg_pay_day' 
                    , 'std_pay_day' 
                    , 'collected_amount_pending' 
                    , 'amount_approved' 
                    , 'amount_rejected' 
                    , 'amount_pending' 
                    , 'amount_cancelled' 
                    , 'amount_charged_back' 
                    , 'amount_in_process' 
                    , 'amount_refunded' 
                    , 'collected_amount_approved' 
                    , 'collected_amount_rejected' 
                    , 'collected_amount_cancelled' 
                    , 'collected_amount_charged_back' 
                    , 'collected_amount_in_process' 
                    , 'collected_amount_refunded' 
                    , 'analytics_camp_view_dif_google_dif_t_t1' 
                    , 'analytics_camp_view_dif_google_dif_t_avg_year' 
                    , 'analytics_camp_view_dif_google_dif_t_avg_semester' 
                    , 'analytics_camp_view_dif_google_dif_t_avg_quarter' 
                    , 'analytics_camp_view_fb_dif_t_t1' 
                    , 'analytics_camp_q_donations_dif_t_t1' 
                    , 'analytics_camp_view_dif_t_avg_quarter' 
                    , 'analytics_camp_view_dif_t_avg_semester' 
                    , 'analytics_camp_q_donations_dif_t_avg_year' 
                    , 'analytics_camp_view_dif_t_avg_year' 
                    , 'analytics_camp_q_donations_dif_t_avg_quarter' 
                    , 'analytics_camp_q_donations_dif_t_avg_semester' 
                    , 'analytics_camp_view_dif_null_dif_t_t1' 
                    , 'analytics_camp_q_distinct_referral_dif_t_t1' 
                    , 'analytics_camp_q_distinct_referral_dif_t_avg_year' 
                    , 'analytics_camp_q_distinct_referral_dif_t_avg_quarter' 
                    , 'analytics_camp_view_dif_null_dif_t_avg_semester' 
                    , 'analytics_camp_view_dif_null_dif_t_avg_quarter' 
                    , 'analytics_camp_q_distinct_referral_dif_t_avg_semester' 
                    , 'analytics_camp_view_dif_null_dif_t_avg_year' 
                    , 'donor_version_last_update' 
                    , 'organization_id')
