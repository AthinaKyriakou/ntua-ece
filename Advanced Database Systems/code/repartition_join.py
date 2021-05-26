from pyspark import SparkConf, SparkContext
from pyspark.accumulators import AccumulatorParam
import time

SparkContext.setSystemProperty('spark.executor.memory', '1g')
SparkContext.setSystemProperty('spark.driver.memory', '2g')
sc = SparkContext("local", "ads_project_2020")
#sc._conf.getAll()

# reading files from hdfs and converting them to rdd
taxis_rdd = sc.textFile("hdfs://master:9000/yellow_tripvendors_25.csv")
trips_rdd = sc.textFile("hdfs://master:9000/yellow_tripdata_1m.csv")


################### ACCUMULATOR ########################

# accumulator is a list of tuples
class ListAccumulatorParam(AccumulatorParam):
    def zero(self, initialValue):
        return []
    def addInPlace(self, v1, v2):
        v1.append(v2)
        return v1

result_acc = sc.accumulator([], ListAccumulatorParam())


###### COMBINE BY KEY FUNCTIONS ########################

# a new key is found in the partition
def create_combiner(v):
    if v[0] == "L":
        return ([list(v[1:])], [])
    else:
        return ([], [[v[1]]])

# key already found 
def merge_value(key_buffers, v):
    if v[0] == "L":
        return key_buffers[0].append(v[1:])
    else:
        return key_buffers[1].append(v[1])   

# merging results of all partitions for each key
def merge_combiners(bufs1, bufs2):
    return (bufs1[0] + bufs2[0], bufs1[1] + bufs2[1])


################# CROSS PRODUCT ########################

# perform cross-product if the log and ref buffers are not empty
def buff_cross_prod(t):
    k,v = t
    if v[0] and v[1]:
        global result_acc
        for i in v[0]:        # log buffer
            for j in v[1]:    # reference buffer
                result_acc += tuple([k] + i + j)


################# REPARTITION JOIN #####################

def repartition_join(log_rdd, ref_rdd):
    
    # map: key + tagged value pairs
    log = log_rdd.map(lambda line: (int(line.split(",")[0]), tuple("L") + tuple(line.split(",")[1:])))
    ref = ref_rdd.map(lambda line: (int(line.split(",")[0]), ("R", line.split(",")[1])))
    
    # outputs partitioned, sorted and merged by the framework, each key is in different partitions
    full_data = sc.union([log,ref])
    
    # reduce, each key with all related values in each partition
    buffers = full_data.combineByKey(create_combiner, merge_value, merge_combiners)
    
    buffers.foreach(buff_cross_prod)


################### DRIVER CODE #######################

start_time = time.time()

repartition_join(trips_rdd, taxis_rdd)

end_time =  time.time()

print("Repartition join computational time: " + str(end_time - start_time) + " secs\n")

result = [i for i in result_acc.value if i]

f = open("my_repartition_join_output.txt", "w+")

for l in result:
    for i in l:
        tmp = (str(i))
        f.write(tmp)
    f.write("\n")
        
for line in f:
    print line
