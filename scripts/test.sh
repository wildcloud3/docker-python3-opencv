#!/bin/bash
docker ps -f name=pico
TASK_TMP_DIR=TASK_$$_$(date +"%N")
echo "====== TASK $TASK_TMP_DIR started ======"
docker exec -it pico mkdir \-p ./$TASK_TMP_DIR/
docker cp ./ocr-files/words.JPG pico:/home/work/$TASK_TMP_DIR/
docker exec -it pico /bin/bash -c "mkdir -p ./$TASK_TMP_DIR/out/; cd ./$TASK_TMP_DIR/out/; tesseract ../words.JPG phototest -l eng --psm 1 --oem 2 txt pdf hocr"
mkdir -p ./ocr-files/output/$TASK_TMP_DIR/
docker cp pico:/home/work/$TASK_TMP_DIR/out/ ./ocr-files/output/$TASK_TMP_DIR/
docker exec -it pico rm \-r ./$TASK_TMP_DIR/
docker exec -it pico ls
echo "====== Result files was copied to ./ocr-files/output/$TASK_TMP_DIR/ ======"
