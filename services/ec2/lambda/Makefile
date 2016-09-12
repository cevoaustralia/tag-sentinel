ZIPFILE=sentinel_ec2_processor
SOURCES=ec2_process_messages.py config-sentinel.json ../../../common/base_processor.py
ZIP_ARGS="-9rq"

zip: $(SOURCES)
	zip -j $(ZIP_ARGS) $(ZIPFILE).zip $(SOURCES)

clean:
	rm -f $(ZIPFILE).zip *.pyc

run:
	python ec2_processor.py
