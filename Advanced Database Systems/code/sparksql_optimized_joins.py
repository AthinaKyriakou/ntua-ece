import pyspark
from pyspark import SparkContext, SparkConf
from pyspark.sql import SparkSession, SQLContext
import time

SparkContext.setSystemProperty('spark.executor.memory', '1g')
SparkContext.setSystemProperty('spark.driver.memory', '2g')
sc = SparkContext("local", "ads_project_2020")

spark_session = SparkSession.builder.appName("spark_sql_optimizations").getOrCreate()
sqlContext = SQLContext(sc)


########### CONVERT THE HDFS FILES TO APACHE PARQUETS ##########

#taxis = spark_session.read.csv("hdfs://master:9000/yellow_tripvendors_25.csv")
#taxis.write.parquet("hdfs://master:9000/yellow_tripvendors_25.parquet")
#trips = spark_session.read.csv("hdfs://master:9000/yellow_tripdata_1m.csv")
#trips.write.parquet("hdfs://master:9000/yellow_tripdata_1m.parquet")

# load files in Parquet format
taxis_df = sqlContext.read.parquet("hdfs://master:9000/yellow_tripvendors_25.parquet").toDF("trip_id","taxi_id")
trips_df = sqlContext.read.parquet("hdfs://master:9000/yellow_tripdata_1m.parquet").toDF("trip_id","dpt_time","arr_time",
                                                                        "dpt_x","dpt_y","arr_x","arr_y","cost")

#########3##### FIRST JOIN WITH SPARKSQL #######################

start_time = time.time()

result = trips_df.join(taxis_df,"trip_id").explain()

end_time =  time.time()

print("\nComputational time: " + str(end_time - start_time) + " secs")


############## SECOND JOIN WITH SPARKSQL #######################

sqlContext.sql("SET spark.sql.autoBroadcastJoinThreshold = -1")

start_time = time.time()

result = trips_df.join(taxis_df,"trip_id").explain()

end_time =  time.time()

print("\nComputational time: " + str(end_time - start_time) + " secs")