curl -i -L -X PUT -H "Content-Type: text/plain" -d "Welcome to the code challenge " "http://localhost:9870/webhdfs/v1/user/hdfs/iovio.dat?op=CREATE&user.name=hadoop" >> log.txt
curl -i -X POST -L -H "Content-Type: text/plain" -d "we wish you all the best" "http://localhost:9870/webhdfs/v1/user/hdfs/iovio.dat?op=APPEND&user.name=hadoop" >> log.txt
curl -i -L "http://localhost:9870/webhdfs/v1/user/hdfs/iovio.dat?op=OPEN&user.name=hadoop" >> log.txt

if [ "$(curl -L 'http://localhost:9870/webhdfs/v1/user/hdfs/iovio.dat?op=OPEN&user.name=hadoop')" == "Welcome to the code challenge we wish you all the best" ]
then
echo Passed
else
echo Failed
fi
