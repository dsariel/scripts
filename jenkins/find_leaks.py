#!/usr/bin/python

import jenkins
import time
import datetime
import cPickle
import os
import sys

JENKINS_URL='http://...'
JENKINS_USERNAME='...'
JENKINS_PASSWORD='...'
JENKINS_JOB_NAME_PREFIX='rhos-component-ci'

# 2 Days
TIME_THRESHOLD=365*(60*60*24)

#### Cache
# 24 H
CACHE_LIFETIME=5*60*60*24

# 14 days
# Config is slow to obtain and doesn't change much
CACHE_CONFIG_LIFETIME=14*60*60*24

# 30 days
# Build number changes when new build appears so it will
# be retrieved anyway. Worth keeping cache longer.
CACHE_BUILD_LIFETIME=14*60*60*24

CACHE_FOLDER="/tmp/"
DUMP_EVERY=20



current_timestamp = int(time.time())

def dump_cache(cachename, data):
    ''' Function which dumps the data to file using cPickle '''
    try:
        fh = open(CACHE_FOLDER + cachename + ".cpl", "w")
        cPickle.dump(data, fh, True)
        fh.close()
    except:
        pass

def read_cache(cachename, lifetime=CACHE_LIFETIME):
    cache_filepath = CACHE_FOLDER + cachename + ".cpl"
    cache = None
    try:
        if (current_timestamp - int(os.stat(cache_filepath).st_mtime) < lifetime):
            fh = open(cache_filepath, 'r')
            cache = cPickle.load(fh)
            fh.close()
    except:
        pass
    return cache

def get_job_infos(server, cached_job_infos, jobs):
    job_infos = {}
    jobs_count = len(jobs)
    current_no = 1
    for job in jobs:
        job_info = None
        job_name = job.get('fullname')
        if cached_job_infos and job_name in cached_job_infos:
            sys.stdout.write("Getting job info from Cache   %s out of %s \r" % (
                             current_no, jobs_count))
            sys.stdout.flush()
            job_info = cached_job_infos.get(job_name)
        else:
            sys.stdout.write("Getting job info from Jenkins %s out of %s \r" % (
                             current_no, jobs_count))
            sys.stdout.flush()
            job_info = server.get_job_info(job_name)
            if (current_no % DUMP_EVERY == 0 or current_no == jobs_count):
                dump_cache('job_infos', job_infos)
        if job_info:
            job_infos[job_name] = job_info
        current_no += 1
    return job_infos

def get_job_configs(server, cached_job_configs, jobs):
    job_configs = {}
    jobs_count = len(jobs)
    current_no = 1
    for job in jobs:
        job_config = None
        job_name = job.get('fullname')
        if cached_job_configs and job_name in cached_job_configs:
            sys.stdout.write("Getting job config from Cache   %s out of %s \r" % (
                             current_no, jobs_count))
            sys.stdout.flush()
            job_config = cached_job_configs.get(job_name)
        else:
            sys.stdout.write("Getting job config from Jenkins %s out of %s \r" % (
                             current_no, jobs_count))
            sys.stdout.flush()
            job_config = server.get_job_config(job_name)
            if (current_no % DUMP_EVERY == 0 or current_no == jobs_count):
                dump_cache('job_configs', job_configs)
        if job_config:
            job_configs[job_name] = job_config
        current_no += 1
    return job_configs


def get_build_info(server, cached_build_infos, job_name, build_number):
    if cached_build_infos and job_name in cached_build_infos:
        build_info = cached_build_infos.get(job_name)
        if build_info and build_number in build_info:
            return build_info.get(build_number)
    build_info = server.get_build_info(job_name, build_number)    
    build_dict = cached_build_infos
    build_with_number = {}
    build_with_number[build_number] = build_info
    build_dict[job_name] = build_with_number
    dump_cache('build_infos', build_dict)
    return build_info


# Main
server = jenkins.Jenkins(JENKINS_URL, username=JENKINS_USERNAME,
                         password=JENKINS_PASSWORD)

jobs = read_cache('jenkins_jobs')
if not jobs:
    jobs = server.get_all_jobs()
    dump_cache('jenkins_jobs', jobs)

cached_job_infos = read_cache('job_infos')
job_infos = get_job_infos(server, cached_job_infos, jobs)

cached_job_configs = read_cache('job_configs', CACHE_CONFIG_LIFETIME)
job_configs = get_job_configs(server, cached_job_configs, jobs)



cached_build_infos = read_cache('build_infos', CACHE_BUILD_LIFETIME)

jobs_count = len(jobs)
current_no = 1
for job in jobs:
    job_name = job.get('fullname')
    job_data = job_infos.get(job_name)
    last_build = job_data.get('lastBuild')
    if last_build:
        last_build_number = last_build.get('number')
        try:
            build_info = get_build_info(server, cached_build_infos, job_name, last_build_number)
            '''timestamp = build_info.get('timestamp')
            if isinstance(timestamp, int) and timestamp > 9999999999:
                timestamp = timestamp/1000 
                if (current_timestamp - timestamp > TIME_THRESHOLD):
                    print job_name'''
        except jenkins.NotFoundException:
            print "Last build for job %s probably deleted." % job_name
    #sys.stdout.write("Getting job build from Jenkins   %s out of %s \r" % (
    #                         current_no, jobs_count))
    #sys.stdout.flush()
    #else:
    #    print job_name
    current_no += 1

sys.stdout.write("                                             \n\r")
sys.stdout.flush()


for job_name in job_configs:
    if JENKINS_JOB_NAME_PREFIX in job_configs[job_name]:
        job_config = job_configs[job_name]
        job_config_str = str(job_config)
        for line in job_config_str.split("\n"):
            if 'cleanup.yml' in line:
                line = line.strip()
                if line.startswith('#'):
                    print job_name

