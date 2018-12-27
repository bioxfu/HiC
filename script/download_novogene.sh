# download ssutil
# https://helpcdn.aliyun.com/document_detail/50452.html 
chmod +x ossutil64

mkdir novogene

AccessKeyId=LTAIN0ibV8QlZOCR
AccessKeySecret=Hu1CQW1l0ekNe6mOFjD9b7WH7gaaTC
Endpoint=oss-cn-hangzhou.aliyuncs.com
oss_path=oss://novo-data-nj/customer-sC1SYsyo/
local_path=novogene

./ossutil64 config -e $Endpoint -i $AccessKeyId -k $AccessKeySecret
./ossutil64 ls $oss_path

./ossutil64 cp $oss_path $local_path -r -f --jobs 3 --parallel 2

cd novogene/RawData
md5sum -c md5.txt 
