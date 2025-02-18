set -e

# Template generation
echo "Generating templates ..."
id=1
for n in 1 2 3 4 5 10 15 20 30 40 50 100; do
    for i in {1..30}; do
        pivot_min=0.5
        pivot_max=0.7
        pivot_only_session_max=2
        pivot_update_rate_max=0.7
        if [[ n -eq 1 ]]; then
            pivot_min=1
        fi
        if [[ n -lt 6 ]]; then
            pivot_max=1
            pivot_only_session_max=1
        fi
        if [[ n -ge 20 ]]; then
            pivot_only_session_max=$((n / 5))
        fi
        if [[ n -ge 50 ]]; then
            pivot_update_rate_max=0.5
        fi
        echo "$n $id $pivot_min $pivot_max $pivot_only_session_max"
        python code/generate_template.py --template_id $id \
            --n_session_min $n \
            --n_session_max $n \
            --proportion_of_session_with_pivot_min $pivot_min \
            --proportion_of_session_with_pivot_max $pivot_max \
            --n_pivot_only_session_min 0 \
            --n_pivot_only_session_max $pivot_only_session_max \
            --n_pivot_per_pivot_session_min 1 \
            --n_pivot_per_pivot_session_max 2 \
            --pivot_update_rate_min 0.3 \
            --pivot_update_rate_max $pivot_update_rate_max \
            --max_update_per_filler 3 \
            --filler_instruction_rate_min 0.5 \
            --filler_instruction_rate_max 0.7 \
            --filler_instruction_update_rate_min 0.5 \
            --filler_instruction_update_rate_max 0.8 \
            --topics_file topics.json \
            --output_dir dataset
        id=$((id + 1))
    done
done

# Prompt generation
echo "Generating prompts ..."
for template_file in dataset/*.json; do
    python code/generate_prompt.py --template_file $template_file --output_dir prompts
done

# Conversation generation
echo "Generating conversations ..."
for prompt_file in prompts/*.json; do
    python code/generate_conversation.py --prompt_file $prompt_file --template_dir dataset
done
