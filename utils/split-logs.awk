# Split MongoDB log file by day.
#
# Timestamps are expected to be in "<YYYY>-<MM>-<DD>T" format. Outputs to
# "out/".
#
# Run:
#
#   awk -f split-logs.awk <MONGODB_LOG_FILE>
#
# For example, run the following on a large unrotated log file:
#
#   awk -f split-logs.awk mongod.log
# 
# Will produce the following files in the out/ directory:
#
#   mongod.log.2015-03-12
#   mongod.log.2015-03-13
#   mongod.log.2015-03-14
#   mongod.log.2015-03-15

BEGIN {
    date = "unknown"
    system("mkdir -p out")
}
{
    if ($1 ~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}T/) {
        split($1, day, "T")
        date = day[1]
    }
    file = ( "out/" FILENAME "." date )
    print >> file
    close(file)
}
