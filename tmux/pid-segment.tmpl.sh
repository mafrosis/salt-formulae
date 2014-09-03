# print the current {{ component_name }} pid

run_segment() {
	# check any pid files exist
	if ! ls /tmp/{{ component_name }}-{{ pillar['app_name'] }}*.pid &> /dev/null; then
		echo "DEAD"
		return 0
	fi

	# print the current {{ component_name }} pid
	pgrep -d "," -P "$(cat /tmp/{{ component_name }}-{{ pillar['app_name'] }}*.pid | awk -vORS=, '{print}' | sed 's/,$/\n/')"

	if [ $? == 1 ]; then
		echo "DEAD"
		return 0
	fi

	return 0
}
