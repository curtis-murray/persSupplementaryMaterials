make_model: generate_topics
	R CMD BATCH Code/create_model.R
generate_topics: run_hSBM
	R CMD BATCH Code/process_topics.R
run_hSBM: preprocess
	conda run -n prostate python Code/hSBM_meta.py
preprocess: validate_data
	R CMD BATCH Code/preprocess.R
validate_data:
	R CMD BATCH Code/validate_formatting.R

