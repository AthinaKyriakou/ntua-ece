from pyspark import SparkConf, SparkContext
from pyspark.accumulators import AccumulatorParam
import sys
import time

SparkContext.setSystemProperty('spark.executor.memory', '1g')
SparkContext.setSystemProperty('spark.driver.memory', '2g')
sc = SparkContext("local", "ads_project_2020")
#sc._conf.getAll()

# reading files from hdfs and converting them to rdd
taxis_rdd = sc.textFile("hdfs://master:9000/yellow_tripvendors_25.csv")
trips_rdd = sc.textFile("hdfs://master:9000/yellow_tripdata_1m.csv")


################### ACCUMULATORS #######################

class ListAccumulatorParam(AccumulatorParam):
    def zero(self, initialValue):
        return []
    def addInPlace(self, v1, v2):
        v1.append(v2)
        return v1

HR_acc = sc.accumulator([], ListAccumulatorParam())
HL_acc = sc.accumulator([], ListAccumulatorParam())
result_acc = sc.accumulator([], ListAccumulatorParam())


##################### PARTITIONING #######################

# using same paritioner for both RDDs to achieve co-partitioning based on the key
trips = trips_rdd.map(lambda line: (int(line.split(",")[0]), line.split(",")[1:])).partitionBy(27)
taxis = taxis_rdd.map(lambda line: (int(line.split(",")[0]), line.split(",")[1])).partitionBy(27)


##################### BROADCAST #######################

# broadcast R and its size
broad_r_size = sum(sys.getsizeof(i) for i in taxis.collect())
broad_taxis = sc.broadcast(taxis.collectAsMap())


################# INIT() AND MAP() #####################

def init_n_map(iterator):
    
    elements_in_partition = []
    for it in iterator:
        elements_in_partition.append(it)
    
    l_block_size = sum(sys.getsizeof(i) for i in elements_in_partition)
    
    # initialize hashtable for Li
    global HL_acc
    HLi = {}
    c = 0 # HR is not created for this partition (default)
    
    if (broad_r_size < l_block_size):
        global result_acc, HR_acc
        for i in elements_in_partition:
            k, v_l = i
            v_r = broad_taxis.value.get(k)
            if v_r is not None: # if key exists in the reference
                result_acc += tuple([k] + [v_r] + v_l)
        c += 1 # HR is created for this partition
    
    else:
        # add V (a record from an L split) to an HLi hashing its join column
        for i in elements_in_partition:
            k, v_l = i
            HLi[k] = v_l
    
    HL_acc += HLi
    HR_acc += c 


################### DRIVER CODE #######################

start_time = time.time()

trips.foreachPartition(init_n_map)

# close function if HR is not created for an Li (on the driver)
for i in HR_acc.value:
    if (i == 0):
        HLi = HL_acc.value[i]
        # if HLi is not empty, load partition i of R in memory (the RDDs are co-partitioned on the key)
        if HLi: 
            # find number of records per R's partition
            # take() starts from 1, 1st element of the RDD in the 0th partition
            taxis_num_of_records = taxis.mapPartitions(lambda it: [sum(1 for _ in it)]).collect()
            Ri_size = taxis_num_of_records[i]
            for j in range(1,len(Ri_size)+1):
                ri = taxis.take(j) 
                k,v_r = ri
                HLi[k] = v_l
                result_acc += tuple([k] + [v_r] + v_l)
            
end_time =  time.time()

print("Broadcast join computational time: " + str(end_time - start_time) + " secs\n")

result = [i for i in result_acc.value if i]

f = open("my_broadcast_join_output.txt", "w+")
for l in result:
    for i in l:
        tmp = (str(i))
        f.write(tmp)
    f.write("\n")
        
for line in f:
    print line