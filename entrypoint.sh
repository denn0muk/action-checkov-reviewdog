#!/bin/bash

[[ ! -z "$INPUT_SKIP_CHECK" ]] && SKIP_CHECK_FLAG="--skip-check $INPUT_SKIP_CHECK"
[[ ! -z "$INPUT_BASELINE" ]] && CHECK_BASELINE="--baseline $INPUT_BASELINE"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"


# echo "checkov -d $INPUT_WORKING_DIRECTORY --download-external-modules false --quiet $SKIP_CHECK_FLAG -o json > /tmp/tmp"

# checkov -d $INPUT_WORKING_DIRECTORY --download-external-modules $INPUT_DOWNLOAD_EXTERNAL_MODULES --quiet $SKIP_CHECK_FLAG -o json > /tmp/tmp

# echo "=========================================="
# ls -ltrh /tmp/tmp
# cat /tmp/tmp
# echo "=========================================="
# cat /tmp/tmp \
#     | python3 /parse.py
# echo "=========================================="

touch /tmp/output_file
checkov -d $INPUT_WORKING_DIRECTORY $CHECK_BASELINE --download-external-modules $INPUT_DOWNLOAD_EXTERNAL_MODULES --quiet $SKIP_CHECK_FLAG -o json > /tmp/output_file
# echo "=========================================="
ls -ltrh /tmp/output_file
cat /tmp/output_file

# checkov -d $INPUT_WORKING_DIRECTORY $CHECK_BASELINE --download-external-modules $INPUT_DOWNLOAD_EXTERNAL_MODULES --quiet $SKIP_CHECK_FLAG -o json \
cat /tmp/output_file \
    | python3 /parse.py \
    | reviewdog -efm="%f:%l: %m" -name="checkov" -reporter="${INPUT_REPORTER}" -fail-on-error="${INPUT_FAIL_ON_ERROR}" -filter-mode="${INPUT_FILTER_MODE}"

checkov_return="${PIPESTATUS[0]}" reviewdog_return="${PIPESTATUS[2]}" exit_code=$?
echo ::set-output name=checkov-return-code::"${checkov_return}"
echo ::set-output name=reviewdog-return-code::"${reviewdog_return}"

exit $exit_code