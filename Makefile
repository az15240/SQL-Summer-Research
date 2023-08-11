# Processes the queries (including loading the data, creating the views, and running the queries) 
process_files : init
	./process_files.sh

full : init
	./process_files.sh full

medium : init
	./process_files.sh medium

simple : init
	./process_files.sh simple
	
# Downloads data and initializes the view scripts and queries
init : 
	wget https://shrquerylogs.s3-us-west-2.amazonaws.com/sqlshare_data_release1.zip
	unzip sqlshare_data_release1.zip && rm sqlshare_data_release1.zip
	mv Makefile sqlshare_data_release1
	mv 
	./init.sh

count : 
	./count_files.sh

.PHONY : clean
clean : 
	@find data -type f -name "*.db" -exec rm -f {} \;
	cp view_script.txt.bak view_script.txt
	cp queries.txt.bak queries.txt
	rm -f *.bak
	rm -f *.sql
	rm -f *.log
	rm -f *.csv

# .PHONY: clean-databases

# clean-databases:
#     @find data -type f -name "*.db" -exec rm -f {} \;
