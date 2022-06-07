import boto3
import os
import logging
from datetime import datetime, timedelta

from botocore.exceptions import ClientError

cloudhsmv2 = boto3.client('cloudhsmv2')

logger = logging.getLogger()
logger.setLevel(logging.INFO)

DR_REGIONS = os.environ.get('DR_REGIONS', None)
CLUSTER_IDS = os.environ.get('CLUSTER_IDS', None)

def filter_backups(clusterIds):
    hsmBackups = []
    backupFilters = {
        'states': [
            'READY',
        ]
    }

    if clusterIds is not None:
        backupFilters['clusterIds'] = [cid.strip() for cid in clusterIds.split(',')]

    try:
        logger.info('Fetching all backups that are in ready state for cluster(s): {}'.format('All' if clusterIds is None else clusterIds))
        resp = cloudhsmv2.describe_backups(
            Filters=backupFilters,
            SortAscending=False
        )

        logger.info('Filtering CloudHSM backups')
        for b in resp['Backups']:
            if b['CreateTimestamp'] > (datetime.now() - timedelta(days=1)):
                hsmBackups.append(b['BackupId'])
    except (Exception, ClientError) as ce:
        logger.error('Failed to fetch backups. Reason: {}'.format(ce))

    return hsmBackups

def copy_backups(clusterIds, regions):
    hsmBackups = filter_backups(clusterIds)
    drRegions = [region.strip() for region in regions.split(',')]

    if len(hsmBackups) == 0:
        logger.info('No CloudHSM backup found for today\'s date')
        return False

    for bid in hsmBackups:
        for region in drRegions:
            try:
                logger.info('Copying backup {} to {}'.format(bid, region))
                cloudhsmv2.copy_backup_to_region(
                    DestinationRegion=region,
                    BackupId=bid
                )
                logger.info('Backup completed for {} to {}'.format(bid, region))
            except (Exception, ClientError) as ce:
                logger.error('Failed to copy backup {} to {}. Reason: {}'.format(bid, region, ce))

def handler(event, context):
    if DR_REGIONS is None:
        logger.info('Skipping copying CloudHSM backup to another region as DR_REGIONS is empty')
    else:
        copy_backups(CLUSTER_IDS, DR_REGIONS)
