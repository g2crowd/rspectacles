web: bundle exec puma -t ${PUMA_MIN_THREADS:-1}:${PUMA_MAX_THREADS:-1} -w ${PUMA_WORKERS:-1} -p $PORT -e ${RACK_ENV:-development} -C puma.rb
