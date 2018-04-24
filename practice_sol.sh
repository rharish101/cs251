#!/usr/bin/env sh
echo "Solution for part 1"
echo -e "Searching all files in /home/rharish with 'ccsm':"; ls -p ~/ | grep -v --regexp "/$" | grep "ccsm"
sleep 2

echo -e "\nSolution for part 2"
echo -e "Before:"; ./tree
mkdir -p ./A/B/C
echo -e "After:"; ./tree
sleep 2

echo -e "\nSolution for part 3"
wc -wl practice.txt | awk '{print "file=", $3, "lines=", $1, "words=", $2}'
sleep 2

echo -e "\nSolution for part 4"
echo -ne ""; cat data.csv | awk '{print $2}'
sleep 2

echo -e "\nSolution for part 5"
echo -e "Finding all files recursively from /home/rharish with the string 'prof':"; sleep 1; find ~/ -name "*prof*"
sleep 2

echo -e "\nSolution for part 6"
tar -cf Desktop.tar ~/Desktop/; gzip -k Desktop.tar; bzip2 -k Desktop.tar; du -sh Desktop.tar* ~/Desktop/
sleep 2

echo -e "\nSolution for part 7"
vim
sleep 2

echo -e "\nSolution for part 8"
echo -e "1st 4 lines of practice.txt:\n\"\"\""; head -4 practice.txt; echo -e "\"\"\""
sleep 2

echo -e "\nSolution for part 9"
echo -e "Last 4 lines of practice.txt:\n\"\"\""; tail -4 practice.txt; echo -e "\"\"\""
sleep 2

echo -e "\nSolution for part 10"
echo -e "PIDs for chrome:" ; pgrep chrome; top -b -n1 -o %CPU | head -n24 | tail -11 | awk '{sum+=$7; print $0} END{print "Average CPU utilization by top 10 processes=", sum/10}'

rm Desktop.tar* -r ./A/

