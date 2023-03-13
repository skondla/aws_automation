 
import json
import boto3
import random
import sys
import datetime, uuid
from faker import Faker

kinesis = boto3.client('kinesis')

def buildJsonString():
    data = {}
    noVal = 'null'
    new_uuid = uuid.uuid4()
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")
    #now = now.isoformat()
    fake = Faker('en_US')
    data['id'] = random.randint(1000000, 9999999)
    data['name'] = fake.name()
    data['address'] = fake.address()
    data['lat'] = 33.7490
    data['lng'] = 84.3880
    data['created_at'] = now 
    data['updated_at'] = now
    data['phone'] = fake.phone_number()
    data['merchant_id'] = random.randint(100000, 999999)
    data['image'] = noVal
    data['access_token'] = str(new_uuid)
    data['confirmation_code'] = random.randint(100000, 999999)
    data['salt'] = noVal
    data['approved'] = "false"
    data['push_token'] = noVal
    data['uuid'] = str(new_uuid)
    data['email'] = fake.email()
    data['external_id'] = random.randint(1000000, 9999999)
    data['delete_at'] = noVal
    data['facebook_id'] = noVal
    data['extras'] = noVal
    data['original_lat_lng_changed'] = noVal
    data['encrypted_password'] = ""
    data['blocked_email'] = "false"
    data['address_second_line'] = noVal
    data['zipcode'] = noVal
    data['allow_login'] = "false"
    data['stripe_id'] = noVal
    data['original_phone_number'] = fake.phone_number()
    data['last_open_at'] = noVal
    data['last_order_at'] = noVal
    data['uploaded_profile_image'] = noVal
    data['original_lat'] = noVal
    data['original_lng'] = noVal
    data['consecutive_checkins_out_of_geofence'] = 0
    data['allow_sending_email'] = "true"
    data['allow_sending_sms'] = "true"
    data['reset_password_token'] = noVal
    data['reset_password_sent_at'] = noVal
    data['mobile_version'] = noVal
    data['mobile_type'] = 0
    data['mobile_maker'] = noVal
    data['client_version'] = noVal
    data['client_name'] = noVal
    data['city'] = noVal
    data['borough'] = noVal
    data['state'] = noVal
    data['dev'] = noVal
    data['business_code'] = noVal
    data['language'] = noVal
    data['district'] = noVal
    data['house_number'] =noVal
    data['street'] = noVal
    return data

def putRecords(count):
    for i in range(count):
        data = json.dumps(buildJsonString()).replace("}", "}\n")
        print(data)
        kinesis.put_records(
            Records=[
                {
                    'Data': data,
                    'PartitionKey': 'partitionkey'
                },
            ],
            StreamName="ecomm-dev",
        )

def putRecord(count):
    for i in range(count):
        data = json.dumps(buildJsonString()).replace("}", "}\n")
        print(data)
        kinesis.put_record(
            StreamName="ecomm-dev",
            Data=data,
            PartitionKey="partitionkey")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        """ Enter Arguments """
        print('Please Enter batchSize (number of records)')
        exit()
    else:
        putRecords(int(sys.argv[1]))

    