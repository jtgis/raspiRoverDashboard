#!/usr/bin/env bash

# ————— configuration —————
output="/home/jrock/mnt/extdrive/fileshare/index.html"
bar_len=30
# —————————————————————

# 1. cpu temp
if command -v vcgencmd &>/dev/null; then
  temp=$(vcgencmd measure_temp | grep -oP "[0-9]+\.[0-9]+'c")
else
  temp=$(awk '{ printf("%.1f°c\n", $1/1000) }' /sys/class/thermal/thermal_zone0/temp)
fi

# 2. cpu usage and bar
idle=$(top -bn1 | grep -i "cpu(s)" | sed 's/.* \([0-9.]*\)%* id.*/\1/')
cpu_pct=$(awk "BEGIN{printf(\"%.0f\", 100 - $idle)}")
filled=$(awk -v pct=$cpu_pct -v len=$bar_len 'BEGIN{printf(\"%d\", pct/100*len)}')
empty=$((bar_len - filled))
cpu_bar="$(printf "%${filled}s" "" | tr ' ' '|')$(printf "%${empty}s" "")"

# 2a. total cpu cores
cpu_cores=$(nproc)

# 3. ram usage and bar
read mem_total_mb mem_used_mb <<<$(free -m | awk 'tolower($1)=="mem:" {print $2, $3}')
mem_pct=$(awk "BEGIN{printf(\"%.0f\", $mem_used_mb/$mem_total_mb*100)}")
filled=$(awk -v pct=$mem_pct -v len=$bar_len 'BEGIN{printf(\"%d\", pct/100*len)}')
empty=$((bar_len - filled))
ram_bar="$(printf "%${filled}s" "" | tr ' ' '|')$(printf "%${empty}s" "")"

# 3a. total ram human
mem_total_human=$(free -h | awk '/Mem:/ {print tolower($2)}')

# 4. drives anonymized
lsblk_raw=$(lsblk -o fstype,size | tail -n +2)
drive_info=$(echo "$lsblk_raw" | awk '{print "drive" NR " - " $1 " - " $2}')

# 5. download speed
if command -v speedtest-cli &>/dev/null; then
  speed=$(speedtest-cli --simple | grep -i download | awk '{print $2, $3}')
else
  speed="speedtest-cli not installed"
fi

# 6. timestamp
now=$(date '+%Y-%m-%d %h:%m:%s')

# 7. generate html
cat > "$output" <<EOF
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>gemini1 status</title>
  <style>
    body {
      background-color: #6699cc;     /* lighter blue */
      color: #ffffff;               /* white text */
      font-family: courier, monospace;
      text-align: center;
      padding: 2em;
    }
    h1 { margin-bottom: 0.5em; font-style: italic; }
    .section { margin: 1.5em auto; max-width: 600px; }
    .cpu-ram {
      text-align: left;
      background-color: rgba(255,255,255,0.1);
      padding: 1em;
      border-radius: 4px;
      display: inline-block;
      white-space: pre;
    }
    .cpu-ram em { font-style: italic; }
    .cpu-ram strong { font-weight: bold; }
    pre {
      text-align: left;
      background-color: rgba(255,255,255,0.1);
      padding: 1em;
      border-radius: 4px;
      white-space: pre-wrap;
    }
  </style>
</head>
<body>
  <h1>gemini1 status</h1>
  <p><em>last updated: $now</em></p>

  <div class="section">
    <h2>cpu & ram</h2>
    <div class="cpu-ram">
<em><strong>temp:</strong></em>   $temp
<em><strong>cpu:</strong></em>    [${cpu_bar}] $cpu_pct% of $cpu_cores cores
<em><strong>ram:</strong></em>    [${ram_bar}] $mem_pct% of $mem_total_human
    </div>
  </div>

  <div class="section">
    <h2>drive info</h2>
    <pre>$drive_info</pre>
  </div>

  <div class="section">
    <h2>internet download speed</h2>
    <p>$speed</p>
  </div>
</body>
</html>
EOF
