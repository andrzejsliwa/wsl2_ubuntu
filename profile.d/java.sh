export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))
export PATH=/opt/gradle/gradle-7.6/bin:$PATH