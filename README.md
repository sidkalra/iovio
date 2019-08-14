
  
  
# Folders
1. data_definition: run sql script query.sql to make changes to sql server
2. webhdfs: 
 - execute shell script webhdfs.sh to get logs by creating a file in hdfs via webhdfs. Hadoop should be running on the server. Further, user named hadoop should have access to the hdfs filesystem.
 - log.txt contains the logs from one of webhdfs.sh runs
3. environment: Please make sure that buildah and podman are installed to before executing the create_python_image.sh script
4. compression: compares compression algorithm. Please make sure that buildah and podman are installed before executing the create_python_image.sh script
5. instantiate_cloud: instantiates a t2 instance on aws. Please make sure that docker-machine is installed and aws credentials are present in ~/.aws/credentials file
6. q_commands: Few commands in Q language